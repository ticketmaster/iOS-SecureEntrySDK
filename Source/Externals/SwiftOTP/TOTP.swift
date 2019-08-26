
//
//  TOTP.swift
//  SwiftOTP
//
//  Created by Lachlan Bell on 14/1/18.
//  Copyright © 2018 Lachlan Bell. All rights reserved.
//
//  Ticketmaster Modifications © 2018 Kai Cherry

//extension String: Error {}

import Foundation

enum OTPAlgorithm {
  //Hash Algorithm to use, either SHA-1, SHA-256 or SHA-512
  case sha1
  case sha256
  case sha512
}

final class TOTP {
  
  static let shared = TOTP()

  //Digits
  let digits: Int
  
  //Time interval between codes
  let timeInterval: TimeInterval
  
  //Hashing algorithm to use
  let algorithm: OTPAlgorithm
    
  //Initialise TOTP with given parameters
  init(digits: Int = 6, timeInterval: TimeInterval = 15.0, algorithm: OTPAlgorithm = .sha1) {
    self.digits = digits
    self.timeInterval = timeInterval
    self.algorithm = algorithm
  }
  
  //Generate from Monotonic Clock timestamp
  func generate(secret: Data) -> (otp: String, timestamp: UInt64) {
    // Attempt to use sanetime first, but fallback to device time if unavailable
    let timestamp = Clock.timestamp ?? Date().timeIntervalSince1970
    let counter = UInt64(floor(timestamp) / timeInterval)
    let otp = GenerateOTP(
      secret: secret,
      algorithm: algorithm,
      counter: counter,
      digits: digits
    )
    return (otp, counter * UInt64(timeInterval))
  }
}
