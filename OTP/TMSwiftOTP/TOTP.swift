
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

public enum OTPAlgorithm {
	//Hash Algorithm to use, either SHA-1, SHA-256 or SHA-512
	case sha1
	case sha256
	case sha512
}

internal struct TOTP {
    //internal let secret: Data        		//Secret Key
    internal let digits: Int          	//Digits
	internal var timeInterval: TimeInterval		//Time interval between codes
	internal let algorithm: OTPAlgorithm	//Hashing algorithm to use
    fileprivate let keyChain: Keychain
    
    static var shared: TOTP?
    
    static func update() {
        shared = TOTP(15.0)
    }
	
	enum Error: Swift.Error {
		case notFound
	}
    
    //Initialise TOTP with given parameters
	 init?() {
		keyChain = Keychain()
        digits = 6
        timeInterval = 15
        algorithm = .sha1
		
		guard validateDigits(digit: digits) else {
			return nil
		}
    }
    
    init?(_ timeInterval: TimeInterval) {
        self.init()
        self.timeInterval = timeInterval
    }
		
	//Generate from Monotonic Clock timestamp
	internal func generate(secret: Data) -> String? {
        guard let saneTime = Clock.timestamp else {
            return nil
        }
		let counterValue = Int(floor(Double(saneTime) / Double(timeInterval)))
        return GenerateOTP(secret: secret, algorithm: algorithm, counter: UInt64(counterValue), digits: digits)
	}
    
    //Check to see if digits value provided is between 6...8 (specified in RFC 4226)
    fileprivate func validateDigits(digit: Int) -> Bool{
        let validDigits = 6...8
        return validDigits.contains(digit)
    }
    
    //Check to see if time is positive
    fileprivate func validateTime(time: Int) -> Bool {
        return (time > 0)
    }
    
}
