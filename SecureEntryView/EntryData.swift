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

struct EntryData: Decodable {
	
	fileprivate enum CodingKeys : String, CodingKey {
		case barcode = "b"
		case token = "t"
		case customerKey = "ck"
		case eventKey = "ek"
		case renderType = "rt"
	}
	
	enum RenderType {
		// Invalid type
		case INVALID
		// Static QR barcode
		case STATIC_QR
		// Static PDF417 barcode
		case STATIC_PDF
		// RET (rotating entry)
		case ROTATING
	}
	
	fileprivate var barcode: String?
	fileprivate var token: String?
	fileprivate var customerKey: String?
	fileprivate var eventKey: String?
	fileprivate var renderType: RenderType?
	
	internal static func encodeOTPSecretBytes(_ string: String) -> Data? {
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
	
	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		
		// Read barcode value if this is a .BARCODE payload
		do {
			barcode = try values.decode(String.self, forKey: CodingKeys.barcode)
            if let barcode = barcode, barcode.lengthOfBytes(using: String.Encoding.ascii) > 0 {
                renderType = .STATIC_QR
            }
		} catch {
			// Not a barcode payload
		}
		
		// Read rotating symbology keys & token if this is a .ROTATING_SYMBOLOGY payload
		do {
			token = try values.decode(String.self, forKey: CodingKeys.token)
			customerKey = try values.decode(String.self, forKey: CodingKeys.customerKey)
			eventKey = try values.decodeIfPresent(String.self, forKey: CodingKeys.eventKey)
            if let token = token, token.lengthOfBytes(using: String.Encoding.ascii) > 0, let customerKey = customerKey, customerKey.lengthOfBytes(using: String.Encoding.ascii) > 0 {
                renderType = .ROTATING
			}
		} catch {
			// Not a RET token
		}
		
		// If segment type is explicitly specified, use it
		do {
			if let renderType = try values.decodeIfPresent(String.self, forKey: CodingKeys.renderType) {
				switch renderType {
				case "rotating_symbology":
					// Only force RET if an actual token+key is provided
					if let token = token, token.lengthOfBytes(using: String.Encoding.ascii) > 0, let customerKey = customerKey, customerKey.lengthOfBytes(using: String.Encoding.ascii) > 0 {
						self.renderType = .ROTATING;
					} else {
						self.renderType = .STATIC_PDF
					}
					break
				case "barcode":
					// Force rendering of static barcode
					self.renderType = .STATIC_QR;
					break
				default: break
				}
			}
		} catch {
			// No segment type provided
		}
	}
	init(tokenString: String) {
		let decodedData = Data(base64Encoded: tokenString) ?? Data()
		let jsonString = String(data: decodedData, encoding: .utf8) ?? ""
		
		do {
			let jData = jsonString.data(using: .utf8)
			let newEntryData = try JSONDecoder().decode(EntryData.self, from: jData!)
			
			self.barcode = newEntryData.barcode ?? ""
			self.token = newEntryData.token ?? ""
			self.customerKey = newEntryData.customerKey ?? ""
			self.eventKey = newEntryData.eventKey ?? ""
			self.renderType = newEntryData.renderType ?? .INVALID
		} catch let error {
			// Test for valid barcode value, and create static barcode
			if tokenString.range(of: "^[0-9]{12,18}(?:[A-Za-z])?$", options: .regularExpression, range: nil, locale: nil) != nil {
				self.barcode = tokenString
				self.renderType = .STATIC_QR
				return
			}
			print(error)
			print("Exception: Couldn't decode token data")
			return
		}
	}
	
	func getBarcode() -> String {
		return barcode ?? ""
	}
	
	func getToken() -> String {
		return token ?? ""
	}
	
	func getCustomerKey() -> Data? {
		if (customerKey ?? "").lengthOfBytes(using: String.Encoding.ascii) > 0 {
			return EntryData.encodeOTPSecretBytes(customerKey ?? "") ?? Data()
		}
		return nil
	}
	
	func getEventKey() -> Data? {
		if (eventKey ?? "").lengthOfBytes(using: String.Encoding.ascii) > 0 {
			return EntryData.encodeOTPSecretBytes(eventKey ?? "") ?? Data()
		}
		return nil
	}
	
	func getRenderType() -> RenderType {
		return renderType ?? .INVALID
	}
}
