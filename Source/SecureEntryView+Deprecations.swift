//
//  SecureEntryView+Deprecations.swift
//  SecureEntryView
//
//  Created by Vladislav Grigoryev on 11/07/2019.
//  Copyright © 2019 Ticketmaster. All rights reserved.
//

import Foundation

public extension SecureEntryView {
  
  @available(*, deprecated, message: "Use brandingColor property instead")
  func setBrandingColor(color: UIColor!) {
    brandingColor = color
  }
  
  @available(*, deprecated, message: "Use pdf417Subtitle property instead")
  func setPdf417Subtitle(subtitleText: String) {
    pdf417Subtitle = subtitleText
  }
  
  @available(*, deprecated, message: "Use qrSubtitle property instead")
  func setQrCodeSubtitle(subtitleText: String) {
    qrSubtitle = subtitleText
  }
  
  @available(*, deprecated, message: "Use isSubtitleBrandingEnabled property instead")
  func enableBrandedSubtitle(enable: Bool) {
    isSubtitleBrandingEnabled = enable
  }
  
  @available(*, deprecated, renamed: "showError(message:icon:)")
  func showError(text: String?, icon: UIImage? = nil) {
    showError(message: text ?? "", icon: icon)
  }
  
  @available(*, deprecated, message: "Use token and errorMessage properties instead")
  func setToken(token: String!, errorText: String? = nil) {
    self.errorMessage = errorText ?? "Reload ticket"
    self.token = token
  }
  
  @available(*, unavailable)
  func startAnimation() { }
  
  @available(*, deprecated, message: "Use SecureEntryView.syncTime() instead")
  func syncTime(completed: ((_ synced: Bool) -> Void)? = nil) {
    SecureEntryView.syncTime(completion: completed)
  }
}

public extension SecureEntryView {
  
  @available(*, unavailable)
  @objc
  var livePreview: Bool {
    get { return false }
    set { }
  }
  
  @available(*, unavailable)
  @objc
  var staticPreview: Bool {
    get { return false }
    set { }
  }
  
  @available(*, unavailable)
  @objc
  var qrBarcodeSubtitle: String {
    get { return qrSubtitle }
    set { qrSubtitle = newValue }
  }
  
  @available(*, unavailable)
  @objc
  var pdf417BarcodeSubtitle: String {
    get { return pdf417Subtitle }
    set { pdf417Subtitle = newValue }
  }
  
  @available(*, unavailable)
  @objc
  var brandSubtitleText: Bool {
    get { return isSubtitleBrandingEnabled }
    set { isSubtitleBrandingEnabled = newValue }
  }
}
