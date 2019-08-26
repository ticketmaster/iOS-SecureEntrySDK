//
//  String+Truncate.swift
//  SecureEntryView
//
//  Created by Vladislav Grigoryev on 08/07/2019.
//  Copyright © 2019 Ticketmaster. All rights reserved.
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

extension String {
  
  /**
   Truncates the string to the specified length number of characters and appends an optional trailing string if longer.
   
   - Parameter length: A `String`.
   - Parameter trailing: A `String` that will be appended after the truncation.
   
   - Returns: A `String` object.
   */
  func truncate(length: Int, trailing: String = "…") -> String {
    if self.count > length {
      return String(self.prefix(length)) + trailing
    } else {
      return self
    }
  }
}
