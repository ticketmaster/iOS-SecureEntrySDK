//
//  StaticViewController.swift
//  SecureEntryView-Sample
//
//  Created by Karl White on 1/11/19.
//  Copyright © 2019 Ticketmaster. All rights reserved.
//

import Foundation

import UIKit
import Presence

class StaticViewController: UIViewController {
  
  @IBOutlet var staticView: SecureEntryView!
  
  @IBOutlet var staticViewSized: SecureEntryView!
  
  @IBOutlet var staticViewFull: SecureEntryView!
  
  @IBOutlet var staticViewNoToken: SecureEntryView!
  
  @IBOutlet var staticViewInvalid: SecureEntryView!
  
  @IBOutlet var staticCustomError: SecureEntryView!
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // Standard view, rendered at the minimum size (216x160)
    staticView.token = "eyJiIjoiMDg2NzM0NjQ3NjA0MTYxNmEiLCJydCI6ImJhcmNvZGUifQ=="
    
    // Scaled view
    staticViewSized.token = "eyJiIjoiMDg2NzM0NjQ3NjA0MTYxNmEiLCJydCI6ImJhcmNvZGUifQ=="
    staticViewSized.qrSubtitle = ""

    // Large view, rendered edge-to-edge (using v4 RET token format, with no RET keys - which should fall back to Static)
    staticViewFull.token = "eyJiIjoiMDg2NzM0NjQ3NjA0MTYxNmEiLCJydCI6ImJhcmNvZGUifQ=="
    
    // A small static PDF417 (missing RET token/keys) state
    staticViewNoToken.token = "eyJiIjoiODMwNTM2NjY1MTU4ayIsInJ0Ijoicm90YXRpbmdfc3ltYm9sb2d5In0="
    
    // A large invalid (bad token) error state, with a longer error message
    staticViewInvalid.errorMessage = "Custom user guidance can be entered here, 60 char max length"
    staticViewInvalid.token = "ABC123"
    
    // A larger edge-to-edge custom error state, displaying an arbitrary error message within the view
    staticCustomError?.showError(
      message: "Custom error state, still bound by the same 60 character limit",
      icon: UIImage(named: "Static")
    )
  }
}


