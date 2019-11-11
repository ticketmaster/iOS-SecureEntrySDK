//
//  SecureEntryView.State.swift
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
import UIKit

extension SecureEntryView {
  
  enum State {
    
    case none
    
    case loading(image: UIImage)
    
    case qrCode(barcode: String, image: UIImage)
    
    case staticPDF417(barcode: String, image: UIImage, subtitle: String)
    
    case rotatingPDF417(
      rotatingBarcode: String,
      barcode: String?,
      image: UIImage,
      subtitle: String,
      flipped: Bool
    )
    
    case error(message: String, icon: UIImage)
    
    case customError(messsage: String, icon: UIImage)
    
    func update(_ view: SecureEntryView) {
      view.barcodeView.imageView.image = nil
      view.barcodeView.label.text = nil
      
      view.errorView.imageView.image = nil
      view.errorView.label.text = nil
      
      switch self {
      case .none:
        break
        
      case .loading(let image):
        view.barcodeView.imageView.image = image

      case .qrCode(_, let image):
        view.barcodeView.imageView.image = image
        view.barcodeView.imageView.accessibilityLabel = "QR code"
        
      case .staticPDF417(_, let image, let subtitle):
        view.barcodeView.imageView.image = image
        view.barcodeView.imageView.accessibilityLabel = "Barcode"
        
        view.barcodeView.label.text = subtitle
        
      case .rotatingPDF417(_, _, let image, let subtitle, _):
        view.barcodeView.imageView.image = image
        view.barcodeView.imageView.accessibilityLabel = "Barcode"
        
        view.barcodeView.label.text = subtitle
        
      case .error(let message, let icon), .customError(let message, let icon):
        view.errorView.label.text = message
        view.errorView.label.accessibilityLabel = "Error: \(message)"
        view.errorView.imageView.image = icon
      }
      
      view.barcodeView.label.isHidden = view.barcodeView.label.text?.isEmpty ?? true
      view.barcodeView.isHidden = isBarcodeHidden
      view.errorView.isHidden = isErrorViewHidden
      view.scanAnimationView.isHidden = isScanAnimationViewHidden
      
      view.barcodeView.contentInsets = contentEdgeInsets
      view.barcodeView.imageView.transform = barcodeImageViewTransform
    }
  }
}

// MARK: - Changing state
extension SecureEntryView.State {
  
  typealias Error = (message: String, icon: UIImage)

  func reset() -> SecureEntryView.State {
    return .none
  }
  
  func showError(_ error: Error) -> SecureEntryView.State {
    return .error(message: error.message, icon: error.icon)
  }
  
  func showCustomError(_ error: Error) -> SecureEntryView.State {
    return .customError(messsage: error.message, icon: error.icon)
  }
  
  func showQRCode(barcode: String, error: Error) -> SecureEntryView.State {
    guard let image = generateQRBarcode(value: barcode) else {
      return .error(message: error.message, icon: error.icon)
    }
    return .qrCode(barcode: barcode, image: image)
  }
  
  func showRotatingPDF417(
    rotatingBarcode: String,
    barcode: String?,
    pdf417Subtitle: String,
    error: Error
  ) -> SecureEntryView.State {
    if case .rotatingPDF417(let oldRotatingBarcode, _, _, _, let flipped) = self {
      
      // Generate PDF417
      guard let image = generatePDF417(value: rotatingBarcode) else {
        
        // Generate QR Code as a fallback if possible
        guard let barcode = barcode, let image = generateQRBarcode(value: barcode) else {
          return .error(message: error.message, icon: error.icon)
        }
        return .qrCode(barcode: barcode, image: image)
      }
      
      return .rotatingPDF417(
        rotatingBarcode: rotatingBarcode,
        barcode: barcode,
        image: image,
        subtitle: pdf417Subtitle,
        flipped: (rotatingBarcode == oldRotatingBarcode) == flipped
      )
    }
    else {
      // Generate PDF417
      guard let image = generatePDF417(value: rotatingBarcode) else {
        
        // Generate QR Code as a fallback if possible
        guard let barcode = barcode, let image = generateQRBarcode(value: barcode) else {
          return .error(message: error.message, icon: error.icon)
        }
        return .qrCode(barcode: barcode, image: image)
      }
      
      return .rotatingPDF417(
        rotatingBarcode: rotatingBarcode,
        barcode: barcode,
        image: image,
        subtitle: pdf417Subtitle,
        flipped: false
      )
    }
  }
    
  func showStaticPDF417(
    barcode: String,
    pdf417Subtitle: String,
    error: Error
  ) -> SecureEntryView.State {
    guard let image = generatePDF417(value: barcode) else {
      guard let image = generateQRBarcode(value: barcode) else {
        return .error(message: error.message, icon: error.icon)
      }
      return .qrCode(barcode: barcode, image: image)
    }
    
    return .staticPDF417(barcode: barcode, image: image, subtitle: pdf417Subtitle)
  }
}


// MARK: - Updating state
extension SecureEntryView.State {
  
  func setLoadingImage(_ image: UIImage) -> SecureEntryView.State {
    switch self {
      
    case .none:
      return .loading(image: image)
      
    case .loading(let oldImage):
      guard oldImage != image else { return self }
      return .loading(image: image)
      
    default:
      return self
    }
  }
  
  func setPDF417Subtitle(_ subtitle: String) -> SecureEntryView.State {
    switch self {
      
    case .staticPDF417(let barcode, let image, _):
      return .staticPDF417(barcode: barcode, image: image, subtitle: subtitle)
      
    case .rotatingPDF417(let rotatingBarcode, let barcode, let image, _, let flipped):
      return .rotatingPDF417(
        rotatingBarcode: rotatingBarcode,
        barcode: barcode,
        image: image,
        subtitle: subtitle,
        flipped: flipped
      )
      
    default:
      return self
    }
  }
  
  func setErrorMessage(_ message: String) -> SecureEntryView.State {
    switch self {
      
    case .error(_, let icon):
      return .error(message: message, icon: icon)
      
    default:
      return self
    }
  }
}

extension SecureEntryView.State {
  
  var isBarcodeHidden: Bool {
    switch self {
    case .none, .error, .customError:
      return true
    case .loading, .qrCode, .staticPDF417, .rotatingPDF417:
      return false
    }
  }
  
  var isErrorViewHidden: Bool {
    switch self {
    case .none, .loading, .qrCode, .staticPDF417, .rotatingPDF417:
      return true
    case .error, .customError:
      return false
    }
  }
  
  var isScanAnimationViewHidden: Bool {
    switch self {
    case .none, .loading, .qrCode, .error, .customError:
      return true
    case .staticPDF417:
      return false
    case .rotatingPDF417(_, _, _, _, _):
      return false
    }
  }
  
  var barcodeImageViewTransform: CGAffineTransform {
    switch self {
    case .rotatingPDF417(_, _, _, _, _):
      return .init(scaleX: 1.0, y: -1.0)
    default:
      return .identity
    }
  }
  
  var contentEdgeInsets: UIEdgeInsets {
    switch self {
    case .none, .error, .customError:
      return .zero
    case .qrCode:
      return UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
    case .loading, .staticPDF417, .rotatingPDF417:
      return UIEdgeInsets(top: 12.0, left: 12.0, bottom: 12.0, right: 12.0)
    }
  }
}

extension SecureEntryView.State {
  
  static let context = CIContext()
  
  var context: CIContext { return SecureEntryView.State.context }
  
  func generateQRBarcode(value: String) -> UIImage? {
    guard let filter = CIFilter(name: "CIQRCodeGenerator", parameters: [
      "inputCorrectionLevel": "Q",
      "inputMessage": value.dataUsingUTF8StringEncoding
    ]) else { return nil }
    
    guard let image = filter.outputImage else { return nil }
    
    // Remove default paddings to support accurate margins
    let qrCodePadding = UIEdgeInsets(top: 1.0, left: 1.0, bottom: 1.0, right: 1.0)
    guard let cgImage = context.createCGImage(image, from: image.extent.inset(by: qrCodePadding))
      else { return nil }
    
    return UIImage(cgImage: cgImage)
  }
  
  func generatePDF417(value: String) -> UIImage? {
    guard let filter = CIFilter(name: "CIPDF417BarcodeGenerator", parameters: [
      "inputPreferredAspectRatio": 4.0 as NSNumber,
      "inputMessage": value.dataUsingUTF8StringEncoding
    ]) else { return nil }
    
    guard let image = filter.outputImage else { return nil }

    // Remove default paddings to support accurate margins
    let pdfCodePadding = UIEdgeInsets(top: 2.0, left: 2.0, bottom: 2.0, right: 2.0)
    guard let cgImage = context.createCGImage(image, from: image.extent.inset(by: pdfCodePadding))
      else { return nil }
    
    return UIImage(cgImage: cgImage)
  }
}
