//
//  EntryData.swift
//  SecureEntryView
//
//  Created by Karl White on 11/30/18.
//  Copyright © 2018 Ticketmaster. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

extension EntryData {
  
  static let barcodeRegularExpression = try! NSRegularExpression(
    pattern: "^[0-9]{12,18}(?:[A-Za-z])?$",
    options: []
  )

  static func makeRotatingPDF417(
    container: KeyedDecodingContainer<CodingKeys>
  ) throws -> EntryData {
    let token = try container.decode(String.self, forKey: .token)
    let customerKey = try container.decode(String.self, forKey: .customerKey)
    let eventKey = try container.decodeIfPresent(String.self, forKey: .eventKey)
    let barcode = try container.decodeIfPresent(String.self, forKey: .barcode)
    
    guard token.count > 0 else {
      throw DecodingError.dataCorruptedError(
        forKey: CodingKeys.token,
        in: container,
        debugDescription: "Rotating PDF417: Token is empty"
      )
    }
    
    guard customerKey.count > 0 else {
      throw DecodingError.dataCorruptedError(
        forKey: CodingKeys.customerKey,
        in: container,
        debugDescription: "Rotating PDF417: CustomerKey is empty"
      )
    }
    
    guard let customerKeyData = encodeOTPSecretBytes(customerKey) else {
      throw DecodingError.dataCorruptedError(
        forKey: CodingKeys.customerKey,
        in: container,
        debugDescription: "Rotating PDF417: CustomerKey data can not be encoded"
      )
    }
    
    return .rotatingPDF417(
      token: token,
      customerKey: customerKeyData,
      eventKey: eventKey.map(encodeOTPSecretBytes) ?? nil,
      barcode: barcode
    )
  }
  
  static func makeStaticPDF417(
    container: KeyedDecodingContainer<CodingKeys>
  ) throws -> EntryData {
    let barcode = try container.decode(String.self, forKey: .barcode)
    
    guard barcode.count > 0 else {
      throw DecodingError.dataCorruptedError(
        forKey: CodingKeys.barcode,
        in: container,
        debugDescription: "Static PDF417: Barcode is empty"
      )
    }
    
    return .staticPDF417(barcode: barcode)
  }
  
  static func makeQRCode(
    container: KeyedDecodingContainer<CodingKeys>
  ) throws -> EntryData {
    let barcode = try container.decode(String.self, forKey: .barcode)
    
    guard barcode.count > 0 else {
      throw DecodingError.dataCorruptedError(
        forKey: CodingKeys.barcode,
        in: container,
        debugDescription: "QR Code: Barcode is empty"
      )
    }
    
    return .qrCode(barcode: barcode)
  }
  
  static func encodeOTPSecretBytes(_ string: String) -> Data? {
    let length = string.lengthOfBytes(using: .ascii)
    if length & 1 != 0 {
      return nil
    }
    var bytes = [UInt8]()
    bytes.reserveCapacity(length/2)
    var index = string.startIndex
    for _ in 0..<length/2 {
      let nextIndex = string.index(index, offsetBy: 2)
      if let b = UInt8(string[index..<nextIndex], radix: 16) {
        bytes.append(b)
      } else {
        return nil
      }
      index = nextIndex
    }
    return Data(bytes: bytes)
  }
}

enum EntryData {
  
  case invalid
  
  case qrCode(barcode: String)

  case staticPDF417(barcode: String)
  
  case rotatingPDF417(token: String, customerKey: Data, eventKey: Data?, barcode: String?)
}

extension EntryData: Decodable {
  
  enum CodingKeys : String, CodingKey {
    
    case barcode = "b"
    
    case token = "t"
    
    case customerKey = "ck"
    
    case eventKey = "ek"
    
    case renderType = "rt"
  }
  
  enum RenderType: String, Decodable {
    
    case barcode = "barcode"
    
    case rotatingSymbology = "rotating_symbology"
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    switch (try? container.decode(RenderType.self, forKey: .renderType)) {
      
    // Try to make a rotating PDF417, with the static one as a fallback
    case .some(.rotatingSymbology):
      do {
        self = try EntryData.makeRotatingPDF417(container: container)
      }
      catch {
        // Try to make a static PDF417 with the barcode as a fallback
        self = try EntryData.makeStaticPDF417(container: container)
      }
      
    // Try to make a QR code
    case .some(.barcode):
      self = try EntryData.makeQRCode(container: container)
      
    // By default, try to make a rotating PDF417 with a QR code as a fallback
    case .none:
      do {
        self = try EntryData.makeRotatingPDF417(container: container)
      }
      catch {
        // Try to make a QR code with the barcode as a fallback
        self = try EntryData.makeQRCode(container: container)
      }
    }
  }
  
  init(from string: String) {
    guard let data = Data(base64Encoded: string) else {
      self.init(barcode: string)
      return
    }
    
    do {
      self = try JSONDecoder().decode(EntryData.self, from: data)
    }
    catch {
      self.init(barcode: string)
    }
  }
  
  init(barcode: String) {
    let range = NSRange(barcode.startIndex..<barcode.endIndex, in: barcode)
    let match = EntryData.barcodeRegularExpression.firstMatch(
      in: barcode,
      options: [],
      range: range
    )
    
    guard match != nil else {
      self = .invalid
      return
    }
    
    self = .qrCode(barcode: barcode)
  }
}
