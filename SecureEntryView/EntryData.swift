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
	}
	
	enum SegmentType {
		// Invalid type
		case INVALID
		// Static barcode
		case BARCODE
		// RET (rotating entry)
		case ROTATING_SYMBOLOGY
	}
	
	fileprivate var barcode: String?
	fileprivate var token: String?
	fileprivate var customerKey: String?
	fileprivate var eventKey: String?
	fileprivate var segmentType: SegmentType?
	
	fileprivate func encodeOTPSecretBytes(_ string: String) -> Data? {
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
                segmentType = .BARCODE
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
                segmentType = .ROTATING_SYMBOLOGY
            }
		} catch {
			// Not a RET token
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
			self.segmentType = newEntryData.segmentType ?? .INVALID
		} catch let error {
			print(error)
			print("Exception: Couldn't decode data into Blog")
			return
		}
	}
	
	func getBarcode() -> String {
		return barcode ?? ""
	}
	
	func getToken() -> String {
		return token ?? ""
	}
	
	func getCustomerKey() -> Data {
		return encodeOTPSecretBytes(customerKey ?? "") ?? Data()
	}
	
	func getEventKey() -> String {
		return eventKey ?? ""
	}
	
	func getSegmentType() -> SegmentType {
		return segmentType ?? .INVALID
	}
}
