Pod::Spec.new do |spec|

  spec.name         = "iOS-SecureEntrySDK"
  spec.version      = "1.0.1"
  spec.summary      = "TicketMaster iOS-SecureEntrySDK."

  spec.description  = "The SecureEntrySDK allows 3rd party apps and services to display Ticketmaster users’ secured tickets"

  spec.homepage     = "https://github.com/ticketmaster/iOS-SecureEntrySDK"
  # spec.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"

  spec.license      = { :type => "Apache License 2.0", :file => "LICENSE" }

  spec.author       = "TicketMaster"

  spec.platform     = :ios, "10.0"

  spec.source       = { :git => "https://github.com/ticketmaster/iOS-SecureEntrySDK.git", :tag => "#{spec.version}" }

  spec.swift_version = '4.2'

  spec.source_files  = "SecureEntryView/*.{h,swift}", "OTP/3rdParty/*.swift", "OTP/3rdParty/CryptoSwift/**/*.swift", "OTP/TMSwiftOTP/**/*.{h,swift}" 
  spec.exclude_files = "OTP/TMSwiftOTP/Tests/*"

end
