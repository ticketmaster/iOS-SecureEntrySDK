//
//  SecureEntryView+Clock.swift
//  SecureEntryView
//
//  Created by Vladislav Grigoryev on 11/07/2019.
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

// MARK: - Clock
public extension SecureEntryView {
  
  internal static var synced = false
  
  internal static var completions = [((Bool) -> Void)?]()
  
  /**
   Time pool server for time synchronization. The default value is pool.ntp.org.
   */
  static var timePool = "pool.ntp.org"
  
  /**
   Launches time sync with NTP server.
   Happens only once per application launch, besides forced execution.
   At a time only one synchronization is executed.
   
   - parameter force: if true will perform sync even if already was synced.
   - parameter timePool: a server name to be used, the default value is taken from timePool static variable
   - parameter completion: a completion handler
   */
  static func syncTime(
    force: Bool = false,
    timePool: String = timePool,
    completion: ((_ synced: Bool) -> Void)? = nil
  ) {
    guard Thread.isMainThread else {
      DispatchQueue.main.async { syncTime(force: force, timePool: timePool, completion: completion) }
      return
    }
    
    guard !synced || force else {
      completion?(true)
      return
    }
    
    #if !TARGET_INTERFACE_BUILDER
    
    completions.append(completion)
    guard completions.count == 1 else { return }
    
    let localCompletion = { (synced: Bool) in
      completions.forEach { $0?(synced) }
      completions.removeAll()
    }
    
    // It uses the main queue internally
    Clock.sync(
      from: timePool,
      samples: 1,
      first: { (_, _) in synced = true },
      completion: { (_, offset) in localCompletion(offset != nil) }
    )
    #endif // !TARGET_INTERFACE_BUILDER
  }
  
  @available(*, deprecated, renamed: "syncTime(force:completion:)")
  static func syncTime( completed: ((_ synced: Bool) -> Void)?) {
    syncTime(completion: completed)
  }
}
