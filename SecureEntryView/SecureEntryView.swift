//
//  SecureEntryView.swift
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

import UIKit

public struct Presence {

	internal struct SecureEntryConstants {
		struct Keys {
			static let MinOuterWidth = CGFloat(216.0)
			static let MinOuterHeight = CGFloat(160.0)
			static let MinRetWidth = CGFloat(216.0)
			static let MinRetHeight = CGFloat(40.0)
			static let MinStaticWidthHeight = CGFloat(120.0)
			
			static let RetBorderWidth = CGFloat(8.0)
			static let StaticBorderWidth = CGFloat(7.0) // QR is rendered with a transparent border already so effective border will be greater than this value
			
			static let ScanBoxWidth = CGFloat(8.0)
			static let ScanLineWidth = CGFloat(2.0)
			static let ScanAnimDuration = Double(1.5)
			static let ScanAnimStartDelay = Double(0.3)
			static let ScanBoxAnimStartDelay = Double(0.05)
		}
		
		struct Strings {
		}
	}

	@IBDesignable public final class SecureEntryView: UIView {
		
		fileprivate var originalToken: String!
		//fileprivate var entryData: EntryData?
		fileprivate var brandingColor: UIColor?
		fileprivate let timeInterval: TimeInterval = 15
		fileprivate var outerView: UIImageView!
		fileprivate var retImageView: UIImageView!
		fileprivate var staticImageView: UIImageView!
		fileprivate var scanAnimBox: UIView!
		fileprivate var scanAnimLine: UIView!
		fileprivate var timer: Timer?
		fileprivate var type: BarcodeType = .pdf417
		
		enum BarcodeType {
			
			case qr, aztec, pdf417
			
			var filter: CIFilter? {
				switch self {
				case .qr:
					let filter = CIFilter(name: "CIQRCodeGenerator")
					filter?.setValue("Q", forKey: "inputCorrectionLevel")
					return filter
					
				case .aztec:
					return CIFilter(name: "CIAztecCodeGenerator")
					
				case .pdf417:
					return CIFilter(name: "CIPDF417BarcodeGenerator")
				}
			}
		}
		
		public func setToken( token: String! ) {
			guard originalToken != token else {
				return
			}
			
			// Stop renderer
			self.stop()
			
			// Parse token from supplied payload
			originalToken = token
			if token != nil {
				entryData = EntryData(tokenString: token)
				
				// Set 'otpMessage' with message portion
				/*switch( entryData?.getSegmentType() ) {
				case .BARCODE?: otpMessage = entryData?.getBarcode()
				case .ROTATING_SYMBOLOGY?: otpMessage = entryData?.getToken()
				default: return
				}*/
				
				// Kick off renderer
				Clock.sync { date, offset in
					self.start()
				}
			}
		}
		
		public func setBrandingColor( color: UIColor! ) {
			brandingColor = color
		}

		/*
		// Only override draw() if you perform custom drawing.
		// An empty implementation adversely affects performance during animation.
		override func draw(_ rect: CGRect) {
			// Drawing code
		}
		*/

		
		/* Internal */
		override public init(frame: CGRect) {
			super.init(frame: frame)
			self.setup()
		}
		required public init?(coder aDecoder: NSCoder) {
			super.init(coder: aDecoder)
			self.setup()
			
		}
		public func setup() {
			self.setupView()
			Clock.sync { date, offset in
				self.start()
				TOTP.update()
			}
		}
		deinit {
			stop()
		}
		
		fileprivate(set) var flipped = false {
			didSet {
				retImageView.transform = CGAffineTransform(scaleX: 1.0, y: flipped ? -1.0 : 1.0);
			}
		}
		
		var entryData: EntryData? {
			didSet {
				/*guard oldValue != entryData else {
					return
				}*/
				guard let entryData = entryData, (entryData.getSegmentType() == .BARCODE || entryData.getSegmentType() == .ROTATING_SYMBOLOGY) else {
					stop()
					return
				}
				update()
				start()
			}
		}
		
		var fullMessage: String? {
			didSet {
				if retImageView == nil || staticImageView == nil {
					setupView()
				}
				
				guard oldValue != fullMessage else {
					return
				}
				
				guard let fullMessage = fullMessage, let entryData = entryData else {
					retImageView.image = nil
					staticImageView.image = nil
					return
				}
				
				if entryData.getSegmentType() == .ROTATING_SYMBOLOGY {
					// Generate & scale the RET barcode (PDF417)
					if let retFilter = CIFilter(name: "CIPDF417BarcodeGenerator") {
						retFilter.setValue(fullMessage.dataUsingUTF8StringEncoding, forKey: "inputMessage")
						if let scaled = retFilter.outputImage?.transformed(by: CGAffineTransform(scaleX: 5.0, y: 5.0)) {
							let image = UIImage(ciImage: scaled, scale: 2.0, orientation: .up)
							
							// Add inset padding
							let scaleFactor = ( SecureEntryConstants.Keys.MinRetWidth + ( SecureEntryConstants.Keys.RetBorderWidth * 2 ) ) / staticImageView.frame.width
							let insetValue = SecureEntryConstants.Keys.RetBorderWidth * scaleFactor
							let insets = UIEdgeInsets(top: insetValue, left: insetValue, bottom: insetValue, right: insetValue)
							UIGraphicsBeginImageContextWithOptions( CGSize(width: image.size.width + insets.left + insets.right, height: image.size.height + insets.top + insets.bottom), false, image.scale)
							let _ = UIGraphicsGetCurrentContext()
							let origin = CGPoint(x: insets.left, y: insets.top)
							image.draw(at: origin)
							let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()
							UIGraphicsEndImageContext()
							//let imageWithInsets = image
							
							// Apply the image
							retImageView.image = imageWithInsets
							
							flipped = !flipped
						} else {
							retImageView.image = nil
							return
						}
					}
				}
				
				if entryData.getSegmentType() == .BARCODE {
					// Generate & scale the Static barcode (QR)
					if let staticFilter = CIFilter(name: "CIQRCodeGenerator") {
						staticFilter.setValue("Q", forKey: "inputCorrectionLevel")
						staticFilter.setValue(fullMessage.dataUsingUTF8StringEncoding, forKey: "inputMessage")
						if let scaled = staticFilter.outputImage?.transformed(by: CGAffineTransform(scaleX: 10.0, y: 10.0)) {
							let image = UIImage(ciImage: scaled, scale: 2.0, orientation: .up)
							
							// Add inset padding
							let scaleFactor = ( SecureEntryConstants.Keys.MinStaticWidthHeight + ( SecureEntryConstants.Keys.StaticBorderWidth * 2 ) ) / staticImageView.frame.width
							let insetValue = SecureEntryConstants.Keys.StaticBorderWidth * scaleFactor
							let insets = UIEdgeInsets(top: insetValue, left: insetValue, bottom: insetValue, right: insetValue)
							UIGraphicsBeginImageContextWithOptions( CGSize(width: image.size.width + insets.left + insets.right, height: image.size.height + insets.top + insets.bottom), false, image.scale)
							let _ = UIGraphicsGetCurrentContext()
							let origin = CGPoint(x: insets.left, y: insets.top)
							image.draw(at: origin)
							let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()
							UIGraphicsEndImageContext()
							//let imageWithInsets = image
							
							// Apply the image
							staticImageView.image = imageWithInsets
							
						} else {
							staticImageView.image = nil
							return
						}
					}
				}
			}
		}
		
		@objc fileprivate func setupView() {
			var outerRect = self.frame;
			var retRect = outerRect;
			var staticRect = self.frame;
			
			outerRect.size.width = max(SecureEntryConstants.Keys.MinOuterWidth, outerRect.size.width)
			outerRect.size.height = max(SecureEntryConstants.Keys.MinOuterHeight, outerRect.size.height)
			
			retRect.size.width = max(SecureEntryConstants.Keys.MinRetWidth, outerRect.size.width)
			retRect.size.height = max(SecureEntryConstants.Keys.MinRetHeight, retRect.size.width / 5.0)
			
			staticRect.size.width = max(SecureEntryConstants.Keys.MinStaticWidthHeight, min(outerRect.size.width, outerRect.size.height))
			staticRect.size.height = max(SecureEntryConstants.Keys.MinStaticWidthHeight, staticRect.size.width)
			
			if outerView == nil {
				outerView = UIImageView(frame: outerRect);
				outerView.layer.masksToBounds = true
				self.addSubview(outerView)
				
				outerView.center.x = self.bounds.width / 2.0
				outerView.center.y = self.bounds.height / 2.0
				outerView.widthAnchor.constraint(equalToConstant: outerRect.width).isActive = true
				outerView.heightAnchor.constraint(equalToConstant: outerRect.height).isActive = true
				outerView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
				outerView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
			}
			
			if staticImageView == nil {
				staticImageView = UIImageView(frame: staticRect);
				staticImageView.layer.masksToBounds = true
				staticImageView.layer.backgroundColor = UIColor.white.cgColor
				staticImageView.layer.borderWidth = 0
				staticImageView.layer.cornerRadius = 6
				staticImageView.isHidden = true
				outerView.addSubview(staticImageView)
				
				staticImageView.center.x = self.bounds.width / 2.0
				staticImageView.center.y = self.bounds.height / 2.0
				staticImageView.widthAnchor.constraint(equalToConstant: staticRect.width).isActive = true
				staticImageView.heightAnchor.constraint(equalToConstant: staticRect.height).isActive = true
				staticImageView.centerXAnchor.constraint(equalTo: outerView.centerXAnchor).isActive = true
				staticImageView.centerYAnchor.constraint(equalTo: outerView.centerYAnchor).isActive = true
			}
			
			if retImageView == nil {
				retImageView = UIImageView(frame: retRect);
				retImageView.layer.masksToBounds = true
				retImageView.layer.backgroundColor = UIColor.white.cgColor
				retImageView.layer.borderWidth = 0
				retImageView.layer.cornerRadius = 6
				retImageView.isHidden = true
				outerView.addSubview(retImageView)
				
				retImageView.center.x = self.bounds.width / 2.0
				retImageView.center.y = self.bounds.height / 2.0
				retImageView.widthAnchor.constraint(equalToConstant: retRect.width).isActive = true
				retImageView.heightAnchor.constraint(equalToConstant: retRect.height).isActive = true
				retImageView.centerXAnchor.constraint(equalTo: outerView.centerXAnchor).isActive = true
				retImageView.centerYAnchor.constraint(equalTo: outerView.centerYAnchor).isActive = true
			}
			
			if scanAnimBox == nil {
				var boxRect = retRect;
				boxRect.origin.x = 0
				boxRect.size.width = SecureEntryConstants.Keys.ScanBoxWidth
				boxRect.size.height += 0
				scanAnimBox = UIView(frame: boxRect)
				scanAnimBox.backgroundColor = (brandingColor ?? UIColor.blue).withAlphaComponent(0.33)
				scanAnimBox.center.y = outerView.bounds.height / 2.0
				outerView.addSubview(scanAnimBox)
			}
			
			if scanAnimLine == nil {
				var lineRect = retRect;
				lineRect.origin.x = 3
				lineRect.size.width = SecureEntryConstants.Keys.ScanLineWidth
				lineRect.size.height += 16
				scanAnimLine = UIView(frame: lineRect)
				scanAnimLine.backgroundColor = (brandingColor ?? UIColor.blue)
				scanAnimLine.center.y = outerView.bounds.height / 2.0
				outerView.addSubview(scanAnimLine)
			}
		}
		
		@objc fileprivate func startAnimation() {
			setupView()
			if scanAnimBox != nil {
				DispatchQueue.main.async {
					guard let entryData = self.entryData, entryData.getSegmentType() == .ROTATING_SYMBOLOGY else {
						self.scanAnimBox.isHidden = true
						self.scanAnimLine.isHidden = true
						return
					}
					
					self.scanAnimBox.isHidden = false
					self.scanAnimLine.isHidden = false
					self.scanAnimBox.layer.removeAllAnimations()
					self.scanAnimLine.layer.removeAllAnimations()
					
					self.scanAnimBox.center.x = self.scanAnimBox.frame.size.width / 2
					self.scanAnimLine.center.x = self.scanAnimBox.frame.size.width / 2
					UIView.animate(withDuration: SecureEntryConstants.Keys.ScanAnimDuration, delay: SecureEntryConstants.Keys.ScanAnimStartDelay + SecureEntryConstants.Keys.ScanBoxAnimStartDelay, options: [.curveEaseInOut, .repeat, .autoreverse], animations: {
						self.scanAnimBox.center.x = self.retImageView.frame.size.width - ( self.scanAnimBox.frame.size.width / 2 )
					}, completion: nil)
					UIView.animate(withDuration: SecureEntryConstants.Keys.ScanAnimDuration, delay: SecureEntryConstants.Keys.ScanAnimStartDelay, options: [.curveEaseInOut, .repeat, .autoreverse], animations: {
						self.scanAnimLine.center.x = self.retImageView.frame.size.width - ( self.scanAnimBox.frame.size.width / 2 )
					}, completion: nil)
					
					/*UIView.animateKeyframes(withDuration: SecureEntryConstants.Keys.ScanAnimDuration, delay: 0.05, options: [.calculationModeLinear, .repeat, .autoreverse, .overrideInheritedDuration], animations: {
						UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.0) { self.scanAnimBox.center.x = self.scanAnimBox.frame.size.width / 2 }
						UIView.addKeyframe(withRelativeStartTime: 0.01, relativeDuration: 0.25) { self.scanAnimBox.center.x = self.scanAnimBox.frame.size.width / 2 }
						UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.5) { self.scanAnimBox.center.x = self.retImageView.frame.size.width - ( self.scanAnimBox.frame.size.width / 2 ) }
					})
					
					UIView.animateKeyframes(withDuration: SecureEntryConstants.Keys.ScanAnimDuration, delay: 0, options: [.calculationModeLinear, .repeat, .autoreverse, .overrideInheritedDuration], animations: {
						UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.0) { self.scanAnimLine.center.x = self.scanAnimBox.frame.size.width / 2 }
						UIView.addKeyframe(withRelativeStartTime: 0.01, relativeDuration: 0.25) { self.scanAnimLine.center.x = self.scanAnimBox.frame.size.width / 2 }
						UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.5) { self.scanAnimLine.center.x = self.retImageView.frame.size.width - ( self.scanAnimBox.frame.size.width / 2 ) }
					})*/
				}
			}
		}
		
		@objc fileprivate func stopAnimation() {
			guard let scanAnimBox = self.scanAnimBox, let scanAnimLine = self.scanAnimLine else {
				return
			}
			DispatchQueue.main.async {
				scanAnimBox.isHidden = true
				scanAnimBox.layer.removeAllAnimations()
				scanAnimLine.layer.removeAllAnimations()
			}
		}
		
		@objc fileprivate func update() {
			
			guard let entryData = entryData, let retImageView = retImageView, let staticImageView = staticImageView else { return }
			retImageView.isHidden = true
			staticImageView.isHidden = true
			
			if entryData.getSegmentType() == .ROTATING_SYMBOLOGY {
				if TOTP.shared == nil {
					TOTP.update()
				}
				
				guard let totp = TOTP.shared else {
					return
				}
				guard let now = totp.generate(secret: entryData.getCustomerKey()) else {
					return
				}
				
				retImageView.isHidden = false
				fullMessage = (entryData.getToken().replacingOccurrences(of: "🛂", with: "TM")) + "::" + now
			} else if entryData.getSegmentType() == .BARCODE {
				staticImageView.isHidden = false
				fullMessage = entryData.getBarcode()
			}
		}
		
		fileprivate func start() {
			guard timer == nil else {
				return
			}
			timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(update), userInfo: nil, repeats: true)
			timer?.tolerance = 0.25
			startAnimation()
		}
		
		fileprivate func stop() {
			timer?.invalidate()
			timer = nil
			stopAnimation()
		}
	}
}
