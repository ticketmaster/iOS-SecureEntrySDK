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

internal struct SecureEntryConstants {
	struct Keys {
		static let MinOuterWidth = CGFloat(216.0)
		static let MinOuterHeight = CGFloat(160.0)
		static let MinRetWidth = CGFloat(216.0)
		static let MinRetHeight = CGFloat(40.0)
		static let MinStaticWidthHeight = CGFloat(120.0)
		
		static let RetBorderWidth = CGFloat(8.0)
		static let StaticBorderWidth = CGFloat(7.0) // QR is rendered with a transparent border already so effective border will be greater than this value
		
		static let ScanBoxWidth = CGFloat(12.0)
		static let ScanLineWidth = CGFloat(4.0)
		static let ScanAnimDuration = Double(1.5)
		static let ScanAnimStartDelay = Double(0.3)
		static let ScanBoxAnimStartDelay = Double(0.1)
	}
	
	struct Strings {
	}
}

@IBDesignable public final class SecureEntryView: UIView {
    static fileprivate let clockGroup = DispatchGroup()
    static fileprivate var clockDate: Date?
    static fileprivate var clockOffset: TimeInterval?
	
	fileprivate var originalToken: String?
    fileprivate var livePreviewInternal: Bool = false
	fileprivate var staticOnlyInternal: Bool = false
	fileprivate var brandingColorInternal: UIColor?
	fileprivate let timeInterval: TimeInterval = 15
	fileprivate var outerView: UIImageView?
	fileprivate var retImageView: UIImageView?
	fileprivate var staticImageView: UIImageView?
    fileprivate var errorView: UILabel?
	fileprivate var scanAnimBox: UIView?
	fileprivate var scanAnimLine: UIView?
	fileprivate var timer: Timer?
	fileprivate var type: BarcodeType = .pdf417
	
    @IBInspectable fileprivate var livePreview: Bool {
        get {
            return self.livePreviewInternal
        }
        set {
            self.livePreviewInternal = newValue
            self.setupView()
            self.update()
            self.start()
        }
    }
    @IBInspectable fileprivate var staticPreview: Bool {
        get {
            return self.staticOnlyInternal
        }
        set {
            self.staticOnlyInternal = newValue
            self.setupView()
            self.update()
            self.start()
        }
    }
	@IBInspectable fileprivate var brandingColor: UIColor? {
		get {
			return self.brandingColorInternal
		}
		set {
			self.brandingColorInternal = newValue
			if let scanAnimBox = scanAnimBox {
				scanAnimBox.backgroundColor = (brandingColorInternal ?? UIColor.blue).withAlphaComponent(0.5)
			}
			if let scanAnimLine = scanAnimLine {
				scanAnimLine.backgroundColor = (brandingColorInternal ?? UIColor.blue)
			}
		}
	}
	
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
        
        DispatchQueue.main.async {
            guard ( self.originalToken == nil || self.originalToken != token ) else {
                self.start()
                return
            }
            
            // Stop renderer
            self.stop()
            
            // Parse token from supplied payload
            self.originalToken = token
            if token != nil {
                let newEntryData = EntryData(tokenString: token)
                
                guard (newEntryData.getSegmentType() == .BARCODE || newEntryData.getSegmentType() == .ROTATING_SYMBOLOGY) else {
                    self.stop()
                    self.errorView?.isHidden = false
                    self.errorView?.text = "Invalid token"
                    return
                }
                
                self.entryData = newEntryData
                
                self.setupView()
                self.update()
                self.start()
            } else {
                self.errorView?.isHidden = false
                self.errorView?.text = "No token"
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
    @objc fileprivate func setup() {
        #if TARGET_INTERFACE_BUILDER
        guard livePreview == true else { return }
        #endif // TARGET_INTERFACE_BUILDER
        
        self.setupView()
        
        // Kick off a single clock sync
        #if !TARGET_INTERFACE_BUILDER
        DispatchQueue.global(qos: .default).async {
            SecureEntryView.clockGroup.wait()
            guard let _ = SecureEntryView.clockDate, let _ = SecureEntryView.clockOffset else {
                SecureEntryView.clockGroup.enter()
                DispatchQueue.global(qos: .background).async {
                    Clock.sync(from: ClockConstants.TimePools.Apple, samples: 1, first: { date, offset in
                        SecureEntryView.clockDate = date
                        SecureEntryView.clockOffset = offset
                        
                        DispatchQueue.global(qos: .default).async {
                            SecureEntryView.clockGroup.leave()
                        }
                    }, completion: nil)
                }
                return
            }
        }
        #endif //!TARGET_INTERFACE_BUILDER
    }
	deinit {
		stop()
	}
	
	fileprivate(set) var flipped = false {
		didSet {
			retImageView?.transform = CGAffineTransform(scaleX: 1.0, y: flipped ? -1.0 : 1.0);
		}
	}
	
	fileprivate(set) var entryData: EntryData? {
		didSet {
            #if TARGET_INTERFACE_BUILDER
            guard livePreview == true else { return }
            #endif // TARGET_INTERFACE_BUILDER
            
			guard let entryData = entryData, (entryData.getSegmentType() == .BARCODE || entryData.getSegmentType() == .ROTATING_SYMBOLOGY) else {
				stop()
				return
			}
			update()
			//start()
		}
	}
	
	var fullMessage: String? {
		didSet {
			if retImageView == nil || staticImageView == nil || errorView == nil {
				setupView()
			}
			guard ( oldValue == nil || oldValue != fullMessage ) else {
				return
			}
            
            //DispatchQueue.main.async {
                #if !TARGET_INTERFACE_BUILDER
                guard let fullMessage = self.fullMessage, let segmentType = self.entryData?.getSegmentType() else {
                    self.retImageView?.image = nil
                    self.staticImageView?.image = nil
                    self.scanAnimBox?.isHidden = true
                    self.scanAnimLine?.isHidden = true
                    return
                }
                #else
                // Allow interface builder to display dummy sample
                let segmentType = self.staticOnlyInternal ? EntryData.SegmentType.BARCODE : EntryData.SegmentType.ROTATING_SYMBOLOGY
                guard let fullMessage = self.fullMessage else { return }
                #endif //TARGET_INTERFACE_BUILDER
                
                if segmentType == .ROTATING_SYMBOLOGY, let retImageView = self.retImageView {
                    // Generate & scale the RET barcode (PDF417)
                    if let retFilter = CIFilter(name: "CIPDF417BarcodeGenerator") {
                        retFilter.setValue(fullMessage.dataUsingUTF8StringEncoding, forKey: "inputMessage")
                        if let scaled = retFilter.outputImage?.transformed(by: CGAffineTransform(scaleX: 5.0, y: 5.0)) {
                            let image = UIImage(ciImage: scaled, scale: 2.0, orientation: .up)
                            
                            // Add inset padding
                            let scaleFactor = ( SecureEntryConstants.Keys.MinRetWidth + ( SecureEntryConstants.Keys.RetBorderWidth * 2 ) ) / retImageView.frame.width
                            let insetValue = SecureEntryConstants.Keys.RetBorderWidth * scaleFactor
                            let insets = UIEdgeInsets(top: insetValue, left: insetValue, bottom: insetValue, right: insetValue)
                            UIGraphicsBeginImageContextWithOptions( CGSize(width: image.size.width + insets.left + insets.right, height: image.size.height + insets.top + insets.bottom), false, image.scale)
                            let _ = UIGraphicsGetCurrentContext()
                            let origin = CGPoint(x: insets.left, y: insets.top)
                            image.draw(at: origin)
                            let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()
                            UIGraphicsEndImageContext()
                            
                            // Apply the image
                            retImageView.image = imageWithInsets
                            self.scanAnimBox?.isHidden = false
                            self.scanAnimLine?.isHidden = false
                            
                            self.flipped = !self.flipped
                        } else {
                            retImageView.image = nil
                            self.scanAnimBox?.isHidden = true
                            self.scanAnimLine?.isHidden = true
                            return
                        }
                    }
                }
                
                if segmentType == .BARCODE, let staticImageView = self.staticImageView {
                    // Generate & scale the Static barcode (QR)
                    if let staticFilter = CIFilter(name: "CIQRCodeGenerator") {
                        staticFilter.setValue("Q", forKey: "inputCorrectionLevel")
                        staticFilter.setValue(fullMessage.dataUsingUTF8StringEncoding, forKey: "inputMessage")
                        if let scaled = staticFilter.outputImage?.transformed(by: CGAffineTransform(scaleX: 12.0, y: 12.0)) {
                            let image = UIImage(ciImage: scaled, scale: 4.0, orientation: .up)
                            
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
                            
                            // Apply the image
                            staticImageView.image = imageWithInsets
                            
                        } else {
                            staticImageView.image = nil
                            return
                        }
                    }
                }
            //}
		}
	}
	
	@objc fileprivate func setupView() {
        #if TARGET_INTERFACE_BUILDER
        guard livePreview == true else { return }
        #endif // TARGET_INTERFACE_BUILDER
        
		var outerRect = self.frame;
		var retRect = outerRect;
		var staticRect = self.frame;
		
		outerRect.size.width = max(SecureEntryConstants.Keys.MinOuterWidth, outerRect.size.width)
		outerRect.size.height = max(SecureEntryConstants.Keys.MinOuterHeight, outerRect.size.height)
		
		retRect.size.width = max(SecureEntryConstants.Keys.MinRetWidth, outerRect.size.width)
		retRect.size.height = max(SecureEntryConstants.Keys.MinRetHeight, retRect.size.width / 5.0)
		
		staticRect.size.width = max(SecureEntryConstants.Keys.MinStaticWidthHeight, min(outerRect.size.width, outerRect.size.height))
		staticRect.size.height = max(SecureEntryConstants.Keys.MinStaticWidthHeight, staticRect.size.width)
		
		if outerView != nil {} else {
			outerView = UIImageView(frame: outerRect);
			if let outerView = outerView {
				outerView.layer.masksToBounds = true
				self.addSubview(outerView)
				
				outerView.center.x = self.bounds.width / 2.0
				outerView.center.y = self.bounds.height / 2.0
				outerView.translatesAutoresizingMaskIntoConstraints = false
				outerView.widthAnchor.constraint(equalToConstant: outerRect.width).isActive = true
				outerView.heightAnchor.constraint(equalToConstant: outerRect.height).isActive = true
				outerView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
				outerView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
				
				
				if staticImageView != nil {} else {
					staticImageView = UIImageView(frame: staticRect)
					if let staticImageView = staticImageView {
						staticImageView.layer.masksToBounds = true
						staticImageView.layer.backgroundColor = UIColor.white.cgColor
						staticImageView.layer.borderWidth = 0
						staticImageView.layer.cornerRadius = 6
						staticImageView.isHidden = true
						outerView.addSubview(staticImageView)
						
						staticImageView.center.x = self.bounds.width / 2.0
						staticImageView.center.y = self.bounds.height / 2.0
						staticImageView.translatesAutoresizingMaskIntoConstraints = false
						staticImageView.widthAnchor.constraint(equalToConstant: staticRect.width).isActive = true
						staticImageView.heightAnchor.constraint(equalToConstant: staticRect.height).isActive = true
						staticImageView.centerXAnchor.constraint(equalTo: outerView.centerXAnchor).isActive = true
						staticImageView.centerYAnchor.constraint(equalTo: outerView.centerYAnchor).isActive = true
					}
				}
                
                if retImageView != nil {} else {
                    retImageView = UIImageView(frame: retRect)
                    if let retImageView = retImageView {
                        retImageView.layer.masksToBounds = true
                        retImageView.layer.backgroundColor = UIColor.white.cgColor
                        retImageView.layer.borderWidth = 0
                        retImageView.layer.cornerRadius = 6
                        retImageView.isHidden = true
                        outerView.addSubview(retImageView)
                        
                        retImageView.center.x = self.bounds.width / 2.0
                        retImageView.center.y = self.bounds.height / 2.0
                        retImageView.translatesAutoresizingMaskIntoConstraints = false
                        retImageView.widthAnchor.constraint(equalToConstant: retRect.width).isActive = true
                        retImageView.heightAnchor.constraint(equalToConstant: retRect.height).isActive = true
                        retImageView.centerXAnchor.constraint(equalTo: outerView.centerXAnchor).isActive = true
                        retImageView.centerYAnchor.constraint(equalTo: outerView.centerYAnchor).isActive = true
                    }
                }
                
                if errorView != nil {} else {
                    errorView = UILabel(frame: retRect)
                    if let errorView = errorView {
                        errorView.layer.masksToBounds = true
                        errorView.layer.backgroundColor = UIColor.white.cgColor
                        errorView.layer.borderWidth = 0
                        errorView.layer.cornerRadius = 6
                        errorView.isHidden = true
                        outerView.addSubview(errorView)
                        
                        errorView.center.x = self.bounds.width / 2.0
                        errorView.center.y = self.bounds.height / 2.0
                        errorView.translatesAutoresizingMaskIntoConstraints = false
                        errorView.widthAnchor.constraint(equalToConstant: retRect.width).isActive = true
                        errorView.heightAnchor.constraint(equalToConstant: retRect.height).isActive = true
                        errorView.centerXAnchor.constraint(equalTo: outerView.centerXAnchor).isActive = true
                        errorView.centerYAnchor.constraint(equalTo: outerView.centerYAnchor).isActive = true
                        
                        errorView.textColor = UIColor.darkGray
                        errorView.textAlignment = .center
                    }
                }
				
				if scanAnimBox == nil {
					var boxRect = retRect;
					boxRect.origin.x = 0
					boxRect.size.width = SecureEntryConstants.Keys.ScanBoxWidth
					boxRect.size.height += 0
					scanAnimBox = UIView(frame: boxRect)
                    scanAnimBox?.isHidden = true
					
					if let scanAnimBox = scanAnimBox {
						scanAnimBox.backgroundColor = (brandingColorInternal ?? UIColor.blue).withAlphaComponent(0.5)
						scanAnimBox.center.y = outerView.bounds.height / 2.0
						scanAnimBox.translatesAutoresizingMaskIntoConstraints = false
						outerView.addSubview(scanAnimBox)
					}
				}
				
				if scanAnimLine == nil {
					var lineRect = retRect;
					lineRect.origin.x = 3
					lineRect.size.width = SecureEntryConstants.Keys.ScanLineWidth
					lineRect.size.height += 16
					scanAnimLine = UIView(frame: lineRect)
                    scanAnimLine?.isHidden = true
					
					if let scanAnimLine = scanAnimLine {
						scanAnimLine.backgroundColor = (brandingColorInternal ?? UIColor.blue)
						scanAnimLine.center.y = outerView.bounds.height / 2.0
						scanAnimLine.translatesAutoresizingMaskIntoConstraints = false
						outerView.addSubview(scanAnimLine)
					}
				}
			}
		}
		
		#if TARGET_INTERFACE_BUILDER
        retImageView?.isHidden = staticOnlyInternal ? true : false
        scanAnimBox?.isHidden = staticOnlyInternal ? true : false
        scanAnimLine?.isHidden = staticOnlyInternal ? true : false
        staticImageView?.isHidden = staticOnlyInternal ? false : true
        errorView?.isHidden = true
        //self.entryData = EntryData(tokenString: "eyJiIjoiNzgxOTQxNjAzMDAxIiwidCI6IlRNOjowMzo6MjAxeXRmbmllN2tpZmxzZ2hncHQ5ZDR4N2JudTljaG4zYWNwdzdocjdkOWZzc3MxcyIsImNrIjoiMzRkNmQyNTNiYjNkZTIxOTFlZDkzMGY2MmFkOGQ0ZDM4NGVhZTVmNSJ9")
        self.fullMessage = staticOnlyInternal ? "\(staticOnlyInternal)" : "THIS IS A SAMPLE SECURE ENTRY VALUE (Unique ID: \(Date().description(with: Locale.current).hashValue))"
        self.start()
		#endif // TARGET_INTERFACE_BUILDER
	}
	
	@objc fileprivate func startAnimation() {
		if scanAnimBox != nil {
			DispatchQueue.main.async {
				guard let entryData = self.entryData, entryData.getSegmentType() == .ROTATING_SYMBOLOGY, let scanAnimBox = self.scanAnimBox, let scanAnimLine = self.scanAnimLine, let retImageView = self.retImageView else {
					self.scanAnimBox?.isHidden = true
					self.scanAnimLine?.isHidden = true
					return
				}
				
				//scanAnimBox.isHidden = false
				//scanAnimLine.isHidden = false
				scanAnimBox.layer.removeAllAnimations()
				scanAnimLine.layer.removeAllAnimations()
				
				scanAnimBox.center.x = scanAnimBox.frame.size.width / 2
				scanAnimLine.center.x = scanAnimBox.frame.size.width / 2
				UIView.animate(withDuration: SecureEntryConstants.Keys.ScanAnimDuration, delay: SecureEntryConstants.Keys.ScanAnimStartDelay + SecureEntryConstants.Keys.ScanBoxAnimStartDelay, options: [.curveEaseInOut, .repeat, .autoreverse], animations: {
					scanAnimBox.center.x = retImageView.frame.size.width - ( scanAnimBox.frame.size.width / 2 )
				}, completion: nil)
				UIView.animate(withDuration: SecureEntryConstants.Keys.ScanAnimDuration, delay: SecureEntryConstants.Keys.ScanAnimStartDelay, options: [.curveEaseInOut, .repeat, .autoreverse], animations: {
					scanAnimLine.center.x = retImageView.frame.size.width - ( scanAnimBox.frame.size.width / 2 )
				}, completion: nil)
				
				/*UIView.animateKeyframes(withDuration: SecureEntryConstants.Keys.ScanAnimDuration, delay: 0.05, options: [.calculationModeLinear, .repeat, .autoreverse, .overrideInheritedDuration], animations: {
				UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.0) { self.scanAnimBox.center.x = self.scanAnimBox.frame.size.width / 2 }
				UIView.addKeyframe(withRelativeStartTime: 0.01, relativeDuration: 0.25) { self.scanAnimBox.center.x = self.scanAnimBox.frame.size.width / 2 }
				UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.5) { self.scanAnimBox.center.x = self.retImageView?.frame?.size.width - ( self.scanAnimBox.frame.size.width / 2 ) }
				})
				
				UIView.animateKeyframes(withDuration: SecureEntryConstants.Keys.ScanAnimDuration, delay: 0, options: [.calculationModeLinear, .repeat, .autoreverse, .overrideInheritedDuration], animations: {
				UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.0) { self.scanAnimLine.center.x = self.scanAnimBox.frame.size.width / 2 }
				UIView.addKeyframe(withRelativeStartTime: 0.01, relativeDuration: 0.25) { self.scanAnimLine.center.x = self.scanAnimBox.frame.size.width / 2 }
				UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.5) { self.scanAnimLine.center.x = self.retImageView?.frame?.size.width - ( self.scanAnimBox.frame.size.width / 2 ) }
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
        guard let entryData = self.entryData else {
            return
        }
        
        retImageView?.isHidden = true
        staticImageView?.isHidden = true
        errorView?.isHidden = true
        
        if self.entryData?.getSegmentType() == .ROTATING_SYMBOLOGY {
            if TOTP.shared == nil {
                TOTP.update()
            }
            
            guard let totp = TOTP.shared else {
                return
            }
            guard let now = totp.generate(secret: self.entryData?.getCustomerKey() ?? Data()) else {
                return
            }
            
            retImageView?.isHidden = false
            fullMessage = ((self.entryData?.getToken() ?? "").replacingOccurrences(of: "🛂", with: "TM")) + "::" + now
        } else if entryData.getSegmentType() == .BARCODE {
            staticImageView?.isHidden = false
            fullMessage = self.entryData?.getBarcode()
        } else {
            errorView?.isHidden = false
        }
	}
	
	fileprivate func start() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        self.timer?.tolerance = 0.25
        self.startAnimation()
	}
	
	fileprivate func stop() {
        self.timer?.invalidate()
        self.stopAnimation()
	}
}
