//
//  RotatingViewController.swift
//  SecureEntryView-Sample
//
//  Created by Karl White on 1/11/19.
//  Copyright © 2019 Ticketmaster. All rights reserved.
//

import UIKit
import Presence

class RotatingViewController: UIViewController {
  
  @IBOutlet var retView: SecureEntryView!
  
  @IBOutlet var retViewSized: SecureEntryView!
  
  @IBOutlet var retViewFull: SecureEntryView!
  
  @IBOutlet var retViewNoToken: SecureEntryView!
  
  @IBOutlet var retViewInvalid: SecureEntryView!
  
  @IBOutlet var retViewUnloaded: SecureEntryView!
  
  @IBOutlet var retViewNoText: SecureEntryView!
  
  @IBOutlet var retViewBrandedText: SecureEntryView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Pre-sync time, for Rotating Entry
    SecureEntryView.syncTime()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    let v3token = "eyJiIjoiOTY0NTM3MjgzNDIxIiwidCI6IlRNOjowMzo6MjAxeXRmbmllN2tpZmxzZ2hncHQ5ZDR4N2JudTljaG4zYWNwdzdocjdkOWZzc3MxcyIsImNrIjoiMzRkNmQyNTNiYjNkZTIxOTFlZDkzMGY2MmFkOGQ0ZDM4NGVhZTVmNSJ9"
    let v4token = "eyJiIjoiMDg2NzM0NjQ3NjA0MTYxNmEiLCJ0IjoiQkFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFDR2tmNWxkZWZ3WEh3WmpvRmMzcnNEY0RINkpyY2pqOW0yS0liKyIsImNrIjoiNjhhZjY5YTRmOWE2NGU0YTkxZmE0NjBiZGExN2Y0MjciLCJlayI6IjA2ZWM1M2M3NDllNDQ3YTQ4ODAyNTdmNzNkYzNhYmZjIiwicnQiOiJyb3RhdGluZ19zeW1ib2xvZ3kifQ=="
    
    // Standard view, rendered at the minimum size (216x160) (using simple V4 token)
    retView.token = v4token
    
    // Scaled view, with a custom programatically controlled branding color (using V3 token)
    retViewSized.token = v3token
    retViewSized.brandingColor = .green
    
    // Large view, rendered edge-to-edge (using v4 token)
    retViewFull.token = v4token
    
    retViewNoToken.token = nil
    
    // A small invalid (bad token) error state, with a longer error message
    retViewInvalid.errorMessage = "Custom user guidance can be entered here, 60 char max length"
    retViewInvalid.token = "ABC123"
    
    // Scaled View, with no subtitle values for pdf417 or qr.
    retViewNoText.token = v4token
    retViewNoText.pdf417Subtitle = ""
    retViewNoText.qrSubtitle = ""
    
    // Scaled View, with branded subtitle values for pdf417 or qr.
    retViewBrandedText.token = v4token
    retViewBrandedText.brandingColor = .red
    retViewBrandedText.isSubtitleBrandingEnabled = true
  }
}
