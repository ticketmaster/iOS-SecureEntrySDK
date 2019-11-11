//
//  SecureEntryView.swift
//  SecureEntryView
//
//  Created by Karl White on 11/30/18.
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

import UIKit

@IBDesignable
public final class SecureEntryView: UIView {
  
  // MARK: Public variables
  /**
   Subtitle for the PDF417 variant of the SafeTix ticket.
   
   The default value for this property is *"Screenshots won't get you in."*.
   
   - Note:
    Set an *empty* string to hide subtitle.
   */
  @IBInspectable
  public var pdf417Subtitle: String = "Screenshots won't get you in." {
    didSet {
      state = state.setPDF417Subtitle(pdf417Subtitle)
    }
  }
  
  /**
   Error message to display in case of ivalid token
   
   The default value for this property is *"Reload ticket"*.
   */
  @IBInspectable
  public var errorMessage: String = "Reload ticket" {
    didSet {
      state = state.setErrorMessage(errorMessage)
    }
  }
  
  /**
   Token to generate the barcode.
   
   The default value for this property is *nil*.
   */
  public var token: String? {
    didSet {
      guard token != oldValue else { return }
      guard let token = token else {
        entryData = nil
        return
      }
      
      entryData = EntryData(from: token)
    }
  }

  // MARK: Internal variables

  var entryData: EntryData? {
    didSet {
      state = state.reset()
      update()
      UIAccessibility.post(notification: .layoutChanged, argument: nil)
    }
  }

  var state: State = .none {
    didSet {
      state.update(self)
      
      switch state {
      case .rotatingPDF417(_, _, _, _, _):
        
        if case .rotatingPDF417 = oldValue { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] (_) in
          self?.update()
        }
        timer?.tolerance = 0.25
        
      default:
        timer?.invalidate()
        timer = nil
      }
    }
  }

  var timer: Timer?
  
  var loadingImage: UIImage?
  
  // MARK: Subviews
  
  lazy var barcodeView: SubtitledView = {
    let subtitledView = SubtitledView()
    subtitledView.translatesAutoresizingMaskIntoConstraints = false
    return subtitledView
  }()
  
  lazy var errorView: ErrorView = {
    let errorView = ErrorView()
    errorView.translatesAutoresizingMaskIntoConstraints = false
    return errorView
  }()
  
  lazy var scanAnimationView: ScanAnimationView = {
    let scanAnimationView = ScanAnimationView()
    scanAnimationView.translatesAutoresizingMaskIntoConstraints = false
    return scanAnimationView
  }()
  
  // MARK: Overriten Variables
  
  public override var intrinsicContentSize: CGSize {
    return CGSize(width: 220.0, height: 160.0)
  }
  
  // MARK: Initialization
  
  override public init(frame: CGRect) {
		super.init(frame: frame)
		self.setupView()
	}
  
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
  
  deinit {
    timer?.invalidate()
  }
  
  // MARK: Overriten Methods
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    self.setupView()
  }
  
  override public func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()
    
    token = "eyJiIjoiMDg2NzM0NjQ3NjA0MTYxNmEiLCJ0IjoiQkFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFDR2tmNWxkZWZ3WEh3WmpvRmMzcnNEY0RINkpyY2pqOW0yS0liKyIsImNrIjoiNjhhZjY5YTRmOWE2NGU0YTkxZmE0NjBiZGExN2Y0MjciLCJlayI6IjA2ZWM1M2M3NDllNDQ3YTQ4ODAyNTdmNzNkYzNhYmZjIiwicnQiOiJyb3RhdGluZ19zeW1ib2xvZ3kifQ=="
  }
}

// MARK: - Public Methods
public extension SecureEntryView {
  
  /**
   Shows custom error message with icon.
   
   May be hidden by setting *token*.
   
   - Note:
   The maximal lenght is *60* symbols.
   */
  func showError(message: String, icon: UIImage? = nil) {
    state = state.showCustomError((
      message: message.truncate(length: 60, trailing: "..."),
      icon: icon ?? .alert
    ))
  }
}

// MARK: - Internal Methods
extension SecureEntryView {
  
  func setupView() {
    // Kick off a single clock sync (this will be ignored if clock already synced)
    SecureEntryView.syncTime()
    
    addSubviews()
    makeConstraints()
    update()
  }
  
  func addSubviews() {
    addSubview(barcodeView)
    addSubview(scanAnimationView)
    addSubview(errorView)
  }
  
  func makeConstraints() {
    setContentHuggingPriority(.defaultHigh + 1, for: .vertical)
    setContentHuggingPriority(.defaultHigh + 1, for: .horizontal)
    
    setContentCompressionResistancePriority(.required, for: .horizontal)
    setContentCompressionResistancePriority(.required, for: .vertical)
    
    // MARK: Barcode View Constraints
    do {
      barcodeView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor).isActive = true
      barcodeView.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor).isActive = true
      barcodeView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor).isActive = true
      barcodeView.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor).isActive = true
      
      barcodeView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
      barcodeView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
      
      let widthConstraint = barcodeView.widthAnchor.constraint(equalTo: widthAnchor)
      widthConstraint.priority = .defaultHigh
      widthConstraint.isActive = true
    }
    
    // MARK: Scan Animation View Constraints
    do {
      scanAnimationView.widthAnchor.constraint(equalTo: barcodeView.widthAnchor).isActive = true
      scanAnimationView.centerXAnchor.constraint(equalTo: barcodeView.imageView.centerXAnchor).isActive = true
      scanAnimationView.centerYAnchor.constraint(equalTo: barcodeView.imageView.centerYAnchor).isActive = true
      scanAnimationView.heightAnchor.constraint(
        equalTo: barcodeView.imageView.heightAnchor,
        constant: 16.0
        ).isActive = true
    }
    
    // MARK: Error View Constraints
    do {
      errorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
      errorView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
  }
  
  func update() {
    switch entryData {
    case .none:
      state = state.reset()
      
      UIImage.getLoading { [weak self] (image) in
        guard let this = self else { return }
        this.loadingImage = image
        this.state = this.state.setLoadingImage(image)
        if case .loading = this.state {
          UIAccessibility.post(notification: .layoutChanged, argument: nil)
        }
      }
      
    case .some(.invalid):
      state = state.showError((message: errorMessage, icon: .alert))
      
    case .some(.rotatingPDF417(let token, let customerKey, let eventKey, let barcode)):
      let value = generateRotatingPDF417Value(
        token: token,
        customerKey: customerKey,
        eventKey: eventKey
      )
      
      state = state.showRotatingPDF417(
        rotatingBarcode: value,
        barcode: barcode,
        pdf417Subtitle: pdf417Subtitle,
        error: (message: errorMessage, icon: .alert)
      )
      
    case .some(.staticPDF417(let barcode)):
      state = state.showStaticPDF417(
        barcode: barcode,
        pdf417Subtitle: pdf417Subtitle,
        error: (message: errorMessage, icon: .alert)
      )
      
    case .some(.qrCode(let barcode)):
      state = state.showQRCode(
        barcode: barcode,
        error: (message: errorMessage, icon: .alert)
      )
    }
  }
}

// MARK: - Private Methods
private extension SecureEntryView {
  
  func generateRotatingPDF417Value(token: String, customerKey: Data, eventKey: Data?) -> String {
    let totp = TOTP.shared
    let (customerNow, _) = totp.generate(secret: customerKey)
    
    let keys: [String]
    
    if let eventKey = eventKey {
      let (eventNow, eventTimestamp) = totp.generate(secret: eventKey)
      keys = [token, eventNow, customerNow, "\(eventTimestamp)"]
    }
    else {
      keys = [token, customerNow]
    }
    return keys.joined(separator: "::")
  }
}
