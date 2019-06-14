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

internal struct SecureEntryConstants {
	struct Keys {
		static let MinOuterWidth = CGFloat(216.0)
		static let MinOuterHeight = CGFloat(160.0)
		static let MinPDFWidth = CGFloat(200.0)
		static let MinPDFHeight = CGFloat(50.0)
		static let MinQRWidthHeight = CGFloat(120.0)
		static let MinErrorWidth = CGFloat(200.0)
		static let MinErrorHeight = CGFloat(120.0)
		
		static let PDFBorderWidth = CGFloat(8.0)
		static let QRBorderWidth = CGFloat(10.0) // QR is rendered with a transparent border already so effective border will be greater than this value
		static let ScreenShotWidth = CGFloat(200.0)
        static let ScreenShotHeight = CGFloat(50.0)
        
		static let ScanBoxWidth = CGFloat(12.0)
		static let ScanLineWidth = CGFloat(4.0)
		static let ScanAnimDuration = Double(1.5)
		static let ScanAnimStartDelay = Double(0.3)
		static let ScanBoxAnimStartDelay = Double(0.1)
		
		static let ToggleAnimDuration = Double(0.3)
	}
	
	struct Strings {
		static let DefaultErrorText = "Reload ticket"
	}
}

@IBDesignable public final class SecureEntryView: UIView {
	static internal let clockGroup = DispatchGroup()
	static internal var clockDate: Date?
	static internal var clockOffset: TimeInterval?
	
	static public func syncTime( completed: ((_ synced: Bool) -> Void)? = nil ) {
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
						completed?(true)
						
						DispatchQueue.global(qos: .default).async {
							SecureEntryView.clockGroup.leave()
						}
					}, completion: nil)
				}
				return
			}
			completed?(true)
		}
		#endif //!TARGET_INTERFACE_BUILDER
	}
	
	internal var originalToken: String?
	internal var livePreviewInternal: Bool = false
	internal var staticOnlyInternal: Bool = false
	internal var brandingColorInternal: UIColor?
    internal var qrBarcodeSubtitleInternal: String = "Screenshots are not accepted for entry"
    internal var pdf417BarcodeSubtitleInternal: String = "Screenshots are not accepted for entry"
    internal var qrBarcodeSubtitleBlank: Bool = false
    internal var pdf417BarcodeSubtitleBlank: Bool = false
    internal var brandSubtitleTextInternal: Bool = false
	internal let timeInterval: TimeInterval = 15
	internal var outerView: UIImageView?
	internal var loadingImageView: UIImageView? //= WKWebView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
	internal var pdfImageView: UIImageView?
	internal var qrImageView: UIImageView?
	internal var toggleButton: UIButton?
    internal var pdf417SubtitleLabel: UILabel?
    internal var qrSubtitleLabel: UILabel?
	internal var forceQR: Bool = false
    internal var errorText: String?
	internal var errorView: UIView?
	internal var errorIcon: UIImageView?
	internal var errorLabel: UILabel?
	internal var scanAnimBox: UIView?
	internal var scanAnimLine: UIView?
	internal var timer: Timer? = nil
	internal var toggleTimer: Timer? = nil
	
	@IBInspectable internal var livePreview: Bool {
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
	@IBInspectable internal var staticPreview: Bool {
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
	@IBInspectable internal var brandingColor: UIColor? {
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
    
    
    @IBInspectable internal var qrBarcodeSubtitle: String {
        get {
            return self.qrBarcodeSubtitleInternal
        }
        set {
            qrBarcodeSubtitleInternal = newValue
            qrBarcodeSubtitleBlank = newValue.isEmpty
            qrSubtitleLabel?.text = newValue
        }
    }
    
    @IBInspectable internal var pdf417BarcodeSubtitle: String {
        get {
            return self.pdf417BarcodeSubtitleInternal
        }
        set {
            pdf417BarcodeSubtitleInternal = newValue
            pdf417BarcodeSubtitleBlank = newValue.isEmpty
            pdf417SubtitleLabel?.text = newValue
        }
    }
    
    @IBInspectable internal var brandSubtitleText: Bool {
        get {
            return self.brandSubtitleTextInternal
        }
        set {
            self.brandSubtitleTextInternal = newValue
            if newValue {
                pdf417SubtitleLabel?.textColor = brandingColor
                qrSubtitleLabel?.textColor = brandingColor
            } else{
                pdf417SubtitleLabel?.textColor = #colorLiteral(red: 0.1490196078, green: 0.1490196078, blue: 0.1490196078, alpha: 1)
                qrSubtitleLabel?.textColor = #colorLiteral(red: 0.1490196078, green: 0.1490196078, blue: 0.1490196078, alpha: 1)
            }
        }
    }
    
    public func syncTime( completed: ((_ synced: Bool) -> Void)? = nil ) {
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
                        completed?(true)
                        
                        DispatchQueue.global(qos: .default).async {
                            SecureEntryView.clockGroup.leave()
                        }
                    }, completion: nil)
                }
                return
            }
            completed?(true)
        }
        #endif //!TARGET_INTERFACE_BUILDER
    }
	
	public func showError( text: String?, icon: UIImage? = nil ) {
        DispatchQueue.main.async {
            self.errorLabel?.text = (text ?? "").truncate(length: 60, trailing: "...")
            self.errorIcon?.image = icon ?? UIImage(named: "Alert", in: Bundle(for: SecureEntryView.self), compatibleWith: nil)
            self.errorView?.isHidden = false
            self.loadingImageView?.isHidden = true
            self.qrImageView?.isHidden = true
            self.pdfImageView?.isHidden = true
            self.toggleButton?.isHidden = true
            self.scanAnimLine?.isHidden = true
            self.scanAnimBox?.isHidden = true
        }
	}
	
    /**
     Used to pass in the token value to generate the pdf417 barcode.
     
     - Parameter token: The token
     */
	public func setToken( token: String!, errorText: String? = nil ) {
        self.errorText = errorText
        
		DispatchQueue.main.async {
			guard ( self.originalToken == nil || self.originalToken != token ) else {
				self.start()
				return
			}
			
			// Parse token from supplied payload
			self.originalToken = token
			if token != nil {
				let newEntryData = EntryData(tokenString: token)
				
				// Stop renderer
				//self.stop()
                
                // Hide existing errors
                self.errorView?.isHidden = true

				guard !(newEntryData.getRenderType() == .INVALID) else {
					self.showError( text: self.errorText ?? SecureEntryConstants.Strings.DefaultErrorText, icon: nil )
					return
				}
				
				self.entryData = newEntryData
				
				self.setupView()
				self.update()
				self.start()
			} else {
				self.showError( text: self.errorText ?? SecureEntryConstants.Strings.DefaultErrorText, icon: nil )
			}
		}
	}
	
    /**
     Allows the pdf417's animation to be colored. If not set, will use a default color.
     
     - Parameter color: The color which will be used for the animation.
     */
	public func setBrandingColor( color: UIColor! ) {
		brandingColor = color
	}
    
    /**
     Creates a custom subtitle for the pdf417 variant of the SafeTix ticket. Will truncate if longer than the frame. Note: If set to "", the barcode subtitle will be hidden. Default text is "Screenshots not accepted for entry".
     
     - Parameter subtitleText: The text that will be displayed below the PDF417 barcode.
     */
    public func setPdf417Subtitle( subtitleText: String ) {
        pdf417BarcodeSubtitle = subtitleText
    }
    
    /**
     Creates a custom subtitle for the qr variant of the SafeTix ticket. Will truncate if longer than the frame. Note: If set to "", the barcode subtitle will be hidden. Default text is "Screenshots not accepted for entry".
     
     - Parameter subtitleText: The text that will be displayed below the QR barcode.
     */
    public func setQrCodeSubtitle( subtitleText: String ) {
        qrBarcodeSubtitle = subtitleText
    }
    
    /**
     Sets the subtitle text to match the color of the provided brandingColor. Note: It will be set for both QR and PDF417. Default is false.
     
     - Parameter enable: true or false to enable branded subtitle text.
     */
    public func enableBrandedSubtitle( enable: Bool ) {
        brandSubtitleText = enable
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

		// Ensure animation resumes when returning from inactive
		#if swift(>=4.2)
		NotificationCenter.default.addObserver(self, selector: #selector(self.resume), name: UIApplication.didBecomeActiveNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.resume), name: UIApplication.willEnterForegroundNotification, object: nil)
		#elseif swift(>=4.0)
		NotificationCenter.default.addObserver(self, selector: #selector(self.resume), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.resume), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
		#endif

        // Kick off a single clock sync (this will be ignored if clock already synced)
        SecureEntryView.syncTime()
    }
    
	deinit {
		stop()
	}
	
	internal(set) var flipped = false {
		didSet {
			pdfImageView?.transform = CGAffineTransform(scaleX: 1.0, y: flipped ? -1.0 : 1.0);
		}
	}
	
	internal(set) var entryData: EntryData? {
		didSet {
			#if TARGET_INTERFACE_BUILDER
			guard livePreview == true else { return }
			#endif // TARGET_INTERFACE_BUILDER
			
			guard let entryData = entryData, !(entryData.getRenderType() == .INVALID) else {
				stop()
				return
			}
			update()
			//start()
		}
	}
	
	var qrValue: String? {
		didSet {
			if qrImageView == nil || errorView == nil {
				setupView()
			}
			guard ( oldValue == nil || oldValue != qrValue ) else {
				return
			}
			
			if let qrImageView = self.qrImageView, let renderType = self.entryData?.getRenderType() {
                // Generate & scale the Static barcode (QR)
                qrImageView.image = nil
                if let staticFilter = CIFilter(name: "CIQRCodeGenerator") {
                    staticFilter.setValue("Q", forKey: "inputCorrectionLevel")
                    staticFilter.setValue(qrValue?.dataUsingUTF8StringEncoding, forKey: "inputMessage")
                    if let scaled = staticFilter.outputImage {
                        var imageWithInsets: UIImage? = nil
                        
                        // Add inset padding
                        let image = UIImage(ciImage: scaled, scale: 1, orientation: .up)
                        let scaleFactor = ( SecureEntryConstants.Keys.MinQRWidthHeight + ( SecureEntryConstants.Keys.QRBorderWidth * 2 ) ) / qrImageView.frame.width
                        let insetValue = SecureEntryConstants.Keys.QRBorderWidth * scaleFactor
                        var insets = UIEdgeInsets(top: insetValue, left: insetValue, bottom: insetValue, right: insetValue)
                        if !qrBarcodeSubtitleBlank && renderType != .STATIC_QR {
                            insets.bottom = insetValue * 3
                        }
                        UIGraphicsBeginImageContextWithOptions( CGSize(width: qrImageView.bounds.size.width + insets.left + insets.right, height: qrImageView.bounds.size.height + insets.top + insets.bottom), false, 1)
                        if let scaledContext = UIGraphicsGetCurrentContext() {
                            scaledContext.interpolationQuality = .none
                        }
                        image.draw(in: CGRect(x: insetValue, y: insetValue, width: qrImageView.bounds.size.width, height: qrImageView.bounds.size.height))
                        imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()
                        UIGraphicsEndImageContext()
                        
                        // Apply the image
                        qrImageView.layer.magnificationFilter = CALayerContentsFilter.nearest
                        qrImageView.image = imageWithInsets
                        
                        
                        if let labelHeight = qrSubtitleLabel?.frame.size.height {
                            let spaceBelowQR = SecureEntryConstants.Keys.PDFBorderWidth * 3
                            let spacing = (spaceBelowQR - labelHeight) / 2
                            qrSubtitleLabel?.bottomAnchor.constraint(equalTo: qrImageView.bottomAnchor, constant: -spacing).isActive = true
                        }
                    }
                }
			}
		}
	}
	
	var pdfValue: String? {
		didSet {
			if pdfImageView == nil || qrImageView == nil || errorView == nil {
				setupView()
			}
			guard ( oldValue == nil || oldValue != pdfValue ) else {
				return
			}
			
			//DispatchQueue.main.async {
			#if !TARGET_INTERFACE_BUILDER
			guard let pdfValue = self.pdfValue, let renderType = self.entryData?.getRenderType() else {
				self.pdfImageView?.image = nil
				self.qrImageView?.image = nil
				self.scanAnimBox?.isHidden = true
				self.scanAnimLine?.isHidden = true
				return
			}
			#else
			// Allow interface builder to display dummy sample
			let renderType = self.staticOnlyInternal ? EntryData.RenderType.STATIC_QR : EntryData.RenderType.ROTATING
			guard let pdfValue = self.pdfValue else { return }
			#endif //TARGET_INTERFACE_BUILDER
			
			if ( renderType == .ROTATING || renderType == .STATIC_PDF ), let pdfImageView = self.pdfImageView {
                pdfImageView.image = nil
                
				// Generate & scale the RET barcode (PDF417)
				if let retFilter = CIFilter(name: "CIPDF417BarcodeGenerator") {
					retFilter.setValue(pdfValue.dataUsingUTF8StringEncoding, forKey: "inputMessage")
                    retFilter.setValue(SecureEntryConstants.Keys.MinPDFWidth / SecureEntryConstants.Keys.MinPDFHeight, forKey: "inputPreferredAspectRatio")
                    
                    // Add inset padding
                    if let output = retFilter.outputImage {
                        let image = UIImage(ciImage: output, scale: 1, orientation: .up)
                        let scaleFactor = ( SecureEntryConstants.Keys.MinPDFWidth + ( SecureEntryConstants.Keys.PDFBorderWidth * 2 ) ) / pdfImageView.frame.width
                        let insetValue = SecureEntryConstants.Keys.PDFBorderWidth * scaleFactor
                        var insets = UIEdgeInsets(top: insetValue, left: insetValue, bottom: insetValue, right: insetValue)
                        if !pdf417BarcodeSubtitleBlank && renderType == .ROTATING{
                            if flipped{
                                insets.top = insetValue
                                insets.bottom = insetValue * 3
                            } else{
                                insets.top = insetValue * 3
                                insets.bottom = insetValue
                            }
                        }
                        UIGraphicsBeginImageContextWithOptions( CGSize(width: image.size.width + insets.left + insets.right, height: image.size.height + insets.top + insets.bottom), false, 1)
                        if let scaledContext = UIGraphicsGetCurrentContext() {
                            scaledContext.interpolationQuality = .none
                        }
                        let origin = CGPoint(x: insets.left, y: insets.top)
                        image.draw(at: origin)
                        let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()
                        UIGraphicsEndImageContext()
                        
                        // Apply the image
                        pdfImageView.layer.magnificationFilter = CALayerContentsFilter.nearest
                        pdfImageView.image = imageWithInsets
                        
                        if let labelHeight = pdf417SubtitleLabel?.frame.size.height {
                            let spaceBelowQR = SecureEntryConstants.Keys.PDFBorderWidth * 3
                            let spacing = (spaceBelowQR - labelHeight) / 2
                            //Set up constraint for screenshot label
                            pdf417SubtitleLabel?.bottomAnchor.constraint(equalTo: pdfImageView.bottomAnchor, constant: -spacing).isActive = true
                        }
                    }
                    
                    self.flipped = !self.flipped
				}
                
                if pdfImageView.image == nil {
                    self.scanAnimBox?.isHidden = true
                    self.scanAnimLine?.isHidden = true
                    self.showError( text: self.errorText ?? SecureEntryConstants.Strings.DefaultErrorText, icon: nil )
                } else {
                    self.scanAnimBox?.isHidden = false
                    self.scanAnimLine?.isHidden = false
                }
			}
			
			// Always generate QR code (to allow RET<>QR switching)
			if /*renderType == .BARCODE,*/ let qrImageView = self.qrImageView {
                // Generate & scale the Static barcode (QR)
                qrImageView.image = nil
                if let staticFilter = CIFilter(name: "CIQRCodeGenerator") {
                    staticFilter.setValue("Q", forKey: "inputCorrectionLevel")
                    staticFilter.setValue(qrValue?.dataUsingUTF8StringEncoding, forKey: "inputMessage")
                    
                    if let scaled = staticFilter.outputImage {
                        var imageWithInsets: UIImage? = nil
                    
                        // Add inset padding
                        let image = UIImage(ciImage: scaled, scale: 1, orientation: .up)
                        let scaleFactor = ( SecureEntryConstants.Keys.MinQRWidthHeight + ( SecureEntryConstants.Keys.QRBorderWidth * 2 ) ) / qrImageView.frame.width
                        let insetValue = SecureEntryConstants.Keys.QRBorderWidth * scaleFactor
                        var barcodeTextInsetValue = insetValue * 3
                        if qrBarcodeSubtitleBlank {
                            barcodeTextInsetValue = insetValue
                        }
                        let insets = UIEdgeInsets(top: insetValue, left: insetValue, bottom: barcodeTextInsetValue, right: insetValue)
                        UIGraphicsBeginImageContextWithOptions( CGSize(width: qrImageView.bounds.size.width + insets.left + insets.right, height: qrImageView.bounds.size.height + insets.top + insets.bottom), false, 1)
                        if let scaledContext = UIGraphicsGetCurrentContext() {
                            scaledContext.interpolationQuality = .none
                        }
                        image.draw(in: CGRect(x: insetValue, y: insetValue, width: qrImageView.bounds.size.width, height: qrImageView.bounds.size.height))
                        imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()
                        UIGraphicsEndImageContext()
                    
                        // Apply the image
                        qrImageView.layer.magnificationFilter = CALayerContentsFilter.nearest
                        qrImageView.image = imageWithInsets
                    }
                }
			}
		}
	}
	
	@objc fileprivate func toggleMode(_ sender: AnyObject) {
		// Invalidate any existing timer
		self.toggleTimer?.invalidate()
		self.toggleTimer = nil
		
		// Only rotating symbology may be toggled
		if self.entryData?.getRenderType() == .ROTATING || self.entryData?.getRenderType() == .STATIC_PDF {
			self.forceQR = !self.forceQR
		}
		toggleUpdate()
	}
	
	@objc fileprivate func toggleModeOff() {
		self.forceQR = false
		toggleUpdate()
	}
	
	@objc fileprivate func toggleUpdate() {
        // Only rotating symbology may be toggled
        if self.entryData?.getRenderType() == .ROTATING || self.entryData?.getRenderType() == .STATIC_PDF {
            if true == self.forceQR {
                self.update()
                self.pdfImageView?.isHidden = false
                self.pdfImageView?.alpha = 1
                self.scanAnimBox?.isHidden = true
                self.scanAnimLine?.isHidden = true
                self.qrImageView?.isHidden = false
                self.qrImageView?.alpha = 0
                if !qrBarcodeSubtitleBlank{
                    self.pdf417SubtitleLabel?.isHidden = true
                    self.pdf417SubtitleLabel?.alpha = 1
                    self.qrSubtitleLabel?.isHidden = false
                    self.qrSubtitleLabel?.alpha = 0
                }
                
                UIView.animate( withDuration:SecureEntryConstants.Keys.ToggleAnimDuration, delay: 0,
                               options: [.transitionCrossDissolve], animations: {
                    self.pdfImageView?.alpha = 0
                    self.qrImageView?.alpha = 1
                    self.pdf417SubtitleLabel?.alpha = 0
                    self.qrSubtitleLabel?.alpha = 1
                }, completion: { done in
					if true == self.forceQR {
						//self.stopAnimation()
						self.update()
						self.toggleTimer?.invalidate()
                        self.toggleTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false, block: { [weak self] (_) in
                            self?.toggleModeOff()
                        })
					}
                })
                
            } else {
                self.update()
                self.pdfImageView?.isHidden = false
                self.pdfImageView?.alpha = 0
                self.scanAnimBox?.isHidden = true
                self.scanAnimLine?.isHidden = true
                self.qrImageView?.isHidden = false
                self.qrImageView?.alpha = 1
                if !pdf417BarcodeSubtitleBlank{
                    self.pdf417SubtitleLabel?.isHidden = true
                    self.pdf417SubtitleLabel?.alpha = 0
                    self.qrSubtitleLabel?.isHidden = false
                    self.qrSubtitleLabel?.alpha = 1
                }
                UIView.animate( withDuration:SecureEntryConstants.Keys.ToggleAnimDuration, delay: 0,
                                options: [.transitionCrossDissolve], animations: {
                    self.pdfImageView?.alpha = 1
                    self.qrImageView?.alpha = 0
                    self.pdf417SubtitleLabel?.alpha = 1
                    self.qrSubtitleLabel?.alpha = 0
                }, completion: { done in
					if false == self.forceQR {
						self.startAnimation()
					}
                })
            }
        }
    }
	
	@objc fileprivate func setupView() {
		#if TARGET_INTERFACE_BUILDER
		guard livePreview == true else { return }
		#endif // TARGET_INTERFACE_BUILDER
		
		var outerRect = self.frame
		var retRect = outerRect
		var staticRect = self.frame
		var errorRect = self.frame
		var buttonRect = self.frame
        let screenshotTextFieldRect = self.frame
		
		outerRect.size.width = max(SecureEntryConstants.Keys.MinOuterWidth, outerRect.size.width)
		outerRect.size.height = max(SecureEntryConstants.Keys.MinOuterHeight, outerRect.size.height)
		
		let sizeFactor = SecureEntryConstants.Keys.MinOuterWidth / outerRect.size.width
		retRect.size.width = max(SecureEntryConstants.Keys.MinPDFWidth, outerRect.size.width)
		retRect.size.height = max(SecureEntryConstants.Keys.MinPDFHeight, retRect.size.width / 4.0)
		
		staticRect.size.width = max(SecureEntryConstants.Keys.MinQRWidthHeight, outerRect.size.height)
		staticRect.size.height = max(SecureEntryConstants.Keys.MinQRWidthHeight, staticRect.size.width)
		
		errorRect.size.width = max(SecureEntryConstants.Keys.MinErrorWidth, outerRect.size.width * (SecureEntryConstants.Keys.MinErrorWidth/SecureEntryConstants.Keys.MinOuterWidth))
		errorRect.size.height = max(SecureEntryConstants.Keys.MinErrorHeight, errorRect.size.width * (SecureEntryConstants.Keys.MinErrorHeight/SecureEntryConstants.Keys.MinErrorWidth))
		
		buttonRect.size.width = max(SecureEntryConstants.Keys.MinOuterWidth, outerRect.size.width)
		buttonRect.size.height = max(SecureEntryConstants.Keys.MinOuterHeight, outerRect.size.height)
		
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
				
				if loadingImageView != nil {} else {
					loadingImageView = UIImageView(frame: retRect)
					if let loadingImageView = self.loadingImageView {
						loadingImageView.frame = retRect
						loadingImageView.layer.masksToBounds = true
						loadingImageView.layer.backgroundColor = UIColor.white.cgColor
						loadingImageView.layer.borderWidth = 0
						loadingImageView.layer.cornerRadius = 4
						
						if let loadingData = NSDataAsset(name: "Loading", bundle: Bundle(for: SecureEntryView.self)) {
							DispatchQueue.global().async {
								let image = UIImage.gif(data: loadingData.data)
								DispatchQueue.main.async {
									self.loadingImageView?.image = image
								}
							}
						}
						
						loadingImageView.isHidden = false
						outerView.addSubview(loadingImageView)
						loadingImageView.center.x = self.bounds.width / 2.0
						loadingImageView.center.y = self.bounds.height / 2.0
						loadingImageView.translatesAutoresizingMaskIntoConstraints = false
						loadingImageView.widthAnchor.constraint(equalToConstant: retRect.width).isActive = true
						loadingImageView.heightAnchor.constraint(equalToConstant: retRect.height).isActive = true
						loadingImageView.centerXAnchor.constraint(equalTo: outerView.centerXAnchor).isActive = true
						loadingImageView.centerYAnchor.constraint(equalTo: outerView.centerYAnchor).isActive = true
					}
				}
				
				if qrImageView != nil {} else {
					qrImageView = UIImageView(frame: staticRect)
					if let qrImageView = qrImageView {
						qrImageView.layer.masksToBounds = true
						qrImageView.layer.backgroundColor = UIColor.white.cgColor
						qrImageView.layer.borderWidth = 0
						qrImageView.layer.cornerRadius = 4
						qrImageView.isHidden = true
						outerView.addSubview(qrImageView)
						
						qrImageView.center.x = self.bounds.width / 2.0
						qrImageView.center.y = self.bounds.height / 2.0
						qrImageView.translatesAutoresizingMaskIntoConstraints = false
						qrImageView.widthAnchor.constraint(equalToConstant: staticRect.width).isActive = true
						qrImageView.heightAnchor.constraint(equalToConstant: staticRect.height).isActive = true
						qrImageView.centerXAnchor.constraint(equalTo: outerView.centerXAnchor).isActive = true
						qrImageView.centerYAnchor.constraint(equalTo: outerView.centerYAnchor).isActive = true
					}
				}
				
				if pdfImageView != nil {} else {
					pdfImageView = UIImageView(frame: retRect)
					if let pdfImageView = pdfImageView {
						pdfImageView.layer.masksToBounds = true
						pdfImageView.layer.backgroundColor = UIColor.white.cgColor
						pdfImageView.layer.borderWidth = 0
						pdfImageView.layer.cornerRadius = 4
						pdfImageView.isHidden = true
						outerView.addSubview(pdfImageView)
						
						pdfImageView.center.x = self.bounds.width / 2.0
						pdfImageView.center.y = self.bounds.height / 2.0
						pdfImageView.translatesAutoresizingMaskIntoConstraints = false
						pdfImageView.widthAnchor.constraint(equalToConstant: retRect.width).isActive = true
						pdfImageView.heightAnchor.constraint(equalToConstant: retRect.height).isActive = true
						pdfImageView.centerXAnchor.constraint(equalTo: outerView.centerXAnchor).isActive = true
						pdfImageView.centerYAnchor.constraint(equalTo: outerView.centerYAnchor).isActive = true
					}
				}
				
				if toggleButton != nil {} else {
					toggleButton = UIButton(frame: buttonRect)
					if let toggleButton = toggleButton {
						toggleButton.layer.masksToBounds = true
						toggleButton.addTarget(self, action: #selector(self.toggleMode), for: .touchUpInside)
						toggleButton.isHidden = true
						self.addSubview(toggleButton)
						
                        toggleButton.translatesAutoresizingMaskIntoConstraints = false
                        toggleButton.widthAnchor.constraint(equalToConstant: max(SecureEntryConstants.Keys.MinOuterWidth, outerRect.size.width)).isActive = true
                        toggleButton.heightAnchor.constraint(equalToConstant: max(SecureEntryConstants.Keys.MinOuterHeight, outerRect.size.height)).isActive = true
                        toggleButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
                        toggleButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
					}
				}
				
				if errorView != nil {} else {
					errorView = UIView(frame: errorRect)
					if let errorView = errorView {
						errorView.layer.masksToBounds = false
						errorView.layer.backgroundColor = UIColor.white.cgColor
						errorView.layer.borderWidth = 0
						errorView.layer.cornerRadius = 4
						errorView.isHidden = true
						outerView.addSubview(errorView)
						
						errorView.center.x = self.bounds.width / 2.0
						errorView.center.y = self.bounds.height / 2.0
						errorView.translatesAutoresizingMaskIntoConstraints = false
						errorView.widthAnchor.constraint(equalToConstant: errorRect.width).isActive = true
						errorView.heightAnchor.constraint(equalToConstant: errorRect.height).isActive = true
						errorView.centerXAnchor.constraint(equalTo: outerView.centerXAnchor).isActive = true
						errorView.centerYAnchor.constraint(equalTo: outerView.centerYAnchor).isActive = true
						
						if errorIcon != nil {} else {
							var iconRect = errorRect;
							iconRect.size.height = max(32, ( errorRect.size.height / 2 ) - 10)
							iconRect.size.width = iconRect.size.height
							errorIcon = UIImageView(frame: iconRect)
							if let errorIcon = errorIcon {
								errorIcon.layer.masksToBounds = true
								errorIcon.image = UIImage(named: "Alert", in: Bundle(for: SecureEntryView.self), compatibleWith: nil)
								errorView.addSubview(errorIcon)
								
								errorIcon.center.x = self.bounds.width / 2.0
								errorIcon.center.y = self.bounds.height / 2.0
								errorIcon.translatesAutoresizingMaskIntoConstraints = false
								errorIcon.heightAnchor.constraint(lessThanOrEqualToConstant: iconRect.size.height).isActive = true
								errorIcon.heightAnchor.constraint(greaterThanOrEqualToConstant: 32).isActive = true
								errorIcon.addConstraint(NSLayoutConstraint(item: errorIcon, attribute: .height, relatedBy: .equal, toItem: errorIcon, attribute: .width, multiplier: 1, constant: 0))
								errorIcon.centerXAnchor.constraint(equalTo: errorView.centerXAnchor).isActive = true
								errorIcon.topAnchor.constraint(greaterThanOrEqualTo: errorView.topAnchor, constant: 16).isActive = true
								errorIcon.topAnchor.constraint(lessThanOrEqualTo: errorView.topAnchor, constant: (errorRect.size.height * 0.5) - (iconRect.size.height * 0.5) )
							}
						}
						
						if errorLabel != nil {} else {
							var textRect = errorRect;
							textRect.size.width -= 20
							textRect.size.height /= 2
							errorLabel = UILabel(frame: textRect)
							if let errorLabel = errorLabel {
								errorLabel.layer.masksToBounds = true
								errorView.addSubview(errorLabel)
								
								errorLabel.numberOfLines = 0
								errorLabel.center.x = self.bounds.width / 2.0
								errorLabel.center.y = self.bounds.height / 2.0
								errorLabel.translatesAutoresizingMaskIntoConstraints = false
								
								errorLabel.widthAnchor.constraint(equalToConstant: textRect.size.width).isActive = true
								errorLabel.heightAnchor.constraint(lessThanOrEqualToConstant: errorRect.size.height * 0.6).isActive = true
								errorLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
								errorLabel.leadingAnchor.constraint(equalTo: errorView.leadingAnchor, constant: 10).isActive = true
								errorLabel.trailingAnchor.constraint(equalTo: errorView.trailingAnchor, constant: -10).isActive = true
								errorLabel.centerXAnchor.constraint(equalTo: errorView.centerXAnchor).isActive = true
								errorLabel.topAnchor.constraint(equalTo: errorIcon!.bottomAnchor, constant: 8).isActive = true
								errorLabel.bottomAnchor.constraint(lessThanOrEqualTo: errorView.bottomAnchor, constant: -10).isActive = true
								let pushConstraint = errorLabel.bottomAnchor.constraint(equalTo: errorView.bottomAnchor, constant: -errorRect.size.height * 0.3)
								pushConstraint.isActive = true
								pushConstraint.priority = UILayoutPriority(rawValue: 1)
								
								errorLabel.font = UIFont(descriptor: errorLabel.font.fontDescriptor, size: 4 + (8*(1/sizeFactor)))
								errorLabel.textColor = UIColor.darkGray
								errorLabel.textAlignment = .center
							}
						}
					}
				}
                
                if pdf417SubtitleLabel != nil {} else {
                    pdf417SubtitleLabel = UILabel.init(frame: screenshotTextFieldRect)
                    if let screenShotView = pdf417SubtitleLabel, let pdf = pdfImageView{
                        screenShotView.text = pdf417BarcodeSubtitleInternal
                        screenShotView.textColor = #colorLiteral(red: 0.1490196078, green: 0.1490196078, blue: 0.1490196078, alpha: 1)
                        screenShotView.font = UIFont.systemFont(ofSize: 10)
                        screenShotView.layer.masksToBounds = false
                        screenShotView.isHidden = true
                        screenShotView.textAlignment = .center
                        outerView.addSubview(screenShotView)
                        
                        
                        screenShotView.translatesAutoresizingMaskIntoConstraints = false
                        screenShotView.leadingAnchor.constraint(equalTo: pdf.leadingAnchor, constant: 0).isActive = true
                        screenShotView.trailingAnchor.constraint(equalTo: pdf.trailingAnchor, constant: 0).isActive = true
                    }
                }
                
                if qrSubtitleLabel != nil {} else {
                    qrSubtitleLabel = UILabel.init(frame: screenshotTextFieldRect)
                    if let screenShotView = qrSubtitleLabel, let qr = qrImageView{
                        screenShotView.text = qrBarcodeSubtitleInternal
                        screenShotView.textColor = #colorLiteral(red: 0.1490196078, green: 0.1490196078, blue: 0.1490196078, alpha: 1)
                        screenShotView.font = UIFont.systemFont(ofSize: 10)
                        screenShotView.layer.masksToBounds = false
                        screenShotView.isHidden = true
                        screenShotView.textAlignment = .center
                        outerView.addSubview(screenShotView)

                        screenShotView.translatesAutoresizingMaskIntoConstraints = false
                        screenShotView.leadingAnchor.constraint(equalTo: qr.leadingAnchor, constant:  0).isActive = true
                        screenShotView.trailingAnchor.constraint(equalTo: qr.trailingAnchor, constant: 0).isActive = true
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
		pdfImageView?.isHidden = staticOnlyInternal ? true : false
		toggleButton?.isHidden = staticOnlyInternal ? true : false
		scanAnimBox?.isHidden = staticOnlyInternal ? true : false
		scanAnimLine?.isHidden = staticOnlyInternal ? true : false
		qrImageView?.isHidden = staticOnlyInternal ? false : true
		loadingImageView?.isHidden = true
		errorView?.isHidden = true
		//self.entryData = EntryData(tokenString: "eyJiIjoiNzgxOTQxNjAzMDAxIiwidCI6IlRNOjowMzo6MjAxeXRmbmllN2tpZmxzZ2hncHQ5ZDR4N2JudTljaG4zYWNwdzdocjdkOWZzc3MxcyIsImNrIjoiMzRkNmQyNTNiYjNkZTIxOTFlZDkzMGY2MmFkOGQ0ZDM4NGVhZTVmNSJ9")
		self.qrValue = "\(staticOnlyInternal)"
		self.pdfValue = "THIS IS A SAMPLE SECURE ENTRY VALUE (Unique ID: \(Date().description(with: Locale.current).hashValue))"
		self.start()
		#endif // TARGET_INTERFACE_BUILDER
	}
	
	@objc public func startAnimation() {
        // If error is showing, don't display animation
        if self.errorView?.isHidden == false {
            return
        }
        // Only start animation once animation components are initialized
		if scanAnimBox != nil {
            guard let entryData = self.entryData, (entryData.getRenderType() == .ROTATING || entryData.getRenderType() == .STATIC_PDF), let scanAnimBox = self.scanAnimBox, let scanAnimLine = self.scanAnimLine, let pdfImageView = self.pdfImageView else {
                self.scanAnimBox?.isHidden = true
                self.scanAnimLine?.isHidden = true
                return
            }
			
			if self.forceQR == false {
				scanAnimBox.isHidden = false
				scanAnimLine.isHidden = false
			}
            
			if scanAnimBox.layer.animationKeys() == nil || scanAnimLine.layer.animationKeys() == nil {
				scanAnimBox.layer.removeAllAnimations()
	            scanAnimLine.layer.removeAllAnimations()
            
	            scanAnimBox.center.x = scanAnimBox.frame.size.width / 2
	            scanAnimLine.center.x = scanAnimBox.frame.size.width / 2
	            UIView.animate(withDuration: SecureEntryConstants.Keys.ScanAnimDuration, delay: SecureEntryConstants.Keys.ScanAnimStartDelay + SecureEntryConstants.Keys.ScanBoxAnimStartDelay, options: [.curveEaseInOut, .repeat, .autoreverse], animations: {
	                scanAnimBox.center.x = pdfImageView.frame.size.width - ( scanAnimBox.frame.size.width / 2 )
	            }, completion: nil)
	            UIView.animate(withDuration: SecureEntryConstants.Keys.ScanAnimDuration, delay: SecureEntryConstants.Keys.ScanAnimStartDelay, options: [.curveEaseInOut, .repeat, .autoreverse], animations: {
	                scanAnimLine.center.x = pdfImageView.frame.size.width - ( scanAnimBox.frame.size.width / 2 )
	            }, completion: nil)
			}
		}
	}
	
	@objc fileprivate func stopAnimation() {
		guard let scanAnimBox = self.scanAnimBox, let scanAnimLine = self.scanAnimLine else {
			return
		}
		DispatchQueue.main.async {
			scanAnimBox.layer.removeAllAnimations()
			scanAnimLine.layer.removeAllAnimations()
		}
	}
	
	@objc fileprivate func update() {
        // If error is showing, don't update
        if self.errorView?.isHidden == false {
            return
        }
		guard let entryData = self.entryData else {
			return
		}
		
		pdfImageView?.isHidden = true
		qrImageView?.isHidden = true
		toggleButton?.isHidden = true
		errorView?.isHidden = true
        qrSubtitleLabel?.isHidden = true
        pdf417SubtitleLabel?.isHidden = true
		
		if ( self.forceQR == true ) || ( entryData.getRenderType() == .STATIC_QR ) {
			qrImageView?.isHidden = false
			loadingImageView?.isHidden = true
			if self.forceQR == true {
				toggleButton?.isHidden = false
			}
			qrValue = self.entryData?.getBarcode()
            if !qrBarcodeSubtitleBlank && entryData.getRenderType() != .STATIC_QR{
                qrSubtitleLabel?.isHidden = false
            }
		} else if entryData.getRenderType() == .STATIC_PDF {
			pdfImageView?.isHidden = false
			toggleButton?.isHidden = false
			loadingImageView?.isHidden = true
			if self.forceQR == true {
				toggleButton?.isHidden = false
			}
			pdfValue = self.entryData?.getBarcode()
			qrValue = self.entryData?.getBarcode()
		} else if self.entryData?.getRenderType() == .ROTATING {
			if TOTP.shared == nil {
				TOTP.update()
			}
			
			guard let totp = TOTP.shared else {
				self.showError( text: self.errorText ?? SecureEntryConstants.Strings.DefaultErrorText, icon: nil )
				return
			}
			
			pdfImageView?.isHidden = false
			loadingImageView?.isHidden = true
			toggleButton?.isHidden = false
			
			// Get simple barcoee message
			qrValue = self.entryData?.getBarcode()
			
			// Customer key is always required, so fetch it
			guard let customerNow = totp.generate(secret: self.entryData?.getCustomerKey() ?? Data()) else {
				return
			}
			
			// Event key may not be provided, so only generate if available
			if let eventKey = self.entryData?.getEventKey() {
				guard let eventNow = totp.generate(secret: eventKey) else {
					
					return
				}
				
				pdfValue = (self.entryData?.getToken() ?? "") + "::" + eventNow + "::" + customerNow
			} else {
				pdfValue = (self.entryData?.getToken() ?? "") + "::" + customerNow
			}
            if !pdf417BarcodeSubtitleBlank{
                pdf417SubtitleLabel?.isHidden = false
            }
		} else {
			errorView?.isHidden = false
		}
	}
	
	@objc fileprivate func start() {
		self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] (_) in
            self?.update()
        })
		self.timer?.tolerance = 0.25
		DispatchQueue.main.async {
			self.startAnimation()
		}
	}
	
	@objc fileprivate func resume() {
		self.timer?.invalidate()
		self.timer = nil
		self.start()
	}
	
	@objc fileprivate func stop() {
        self.timer?.invalidate()
		self.timer = nil
        self.stopAnimation()
	}
}
