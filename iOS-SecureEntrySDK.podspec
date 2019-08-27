Pod::Spec.new do |spec|

  spec.name         = "iOS-SecureEntrySDK"
  spec.version      = "1.0.8"
  spec.summary      = "TicketMaster iOS-SecureEntrySDK."

  spec.description  = "The SecureEntrySDK allows 3rd party apps and services to display Ticketmaster users’ secured tickets"

  spec.homepage     = "https://github.com/ticketmaster/iOS-SecureEntrySDK"
  # spec.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"

  spec.license      = { :type => "Apache License 2.0", :file => "LICENSE" }

  spec.author       = "TicketMaster"

  spec.platform     = :ios, "10.0"

  spec.source       = { :git => "https://github.com/ticketmaster/iOS-SecureEntrySDK.git", :tag => "#{spec.version}" }

  spec.swift_version = '4.2'

  spec.resources = 'Source/Resources/Media.xcassets'
  spec.source_files  = "Source/**/*.{h,swift}"
  spec.exclude_files = "Source/Externals/SwiftOTP/Tests/*"

end
