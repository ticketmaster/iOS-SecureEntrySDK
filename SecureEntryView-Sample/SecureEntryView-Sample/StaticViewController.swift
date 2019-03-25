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
    
    @IBOutlet weak var staticView: Presence.SecureEntryView?
    @IBOutlet weak var staticViewSized: Presence.SecureEntryView?
    @IBOutlet weak var staticViewFull: Presence.SecureEntryView?
    @IBOutlet weak var staticViewNoToken: Presence.SecureEntryView?
    @IBOutlet weak var staticViewInvalid: Presence.SecureEntryView?
	@IBOutlet weak var staticCustomError: Presence.SecureEntryView?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		
		// Standard view, rendered at the minimum size (216x160)
        staticView?.setToken(token:"eyJiIjogIjE5NzM3OTA2OTQzNDc3OTlhIiwidCI6ICIiLCJjayI6ICIiLCAiZWsiOiAiIn0=")
		
		// Scaled view
        staticViewSized?.setToken(token:"eyJiIjoiMDg2NzM0NjQ3NjA0MTYxNmEiLCJydCI6ImJhcmNvZGUifQ==")
		
		// Large view, rendered edge-to-edge (using v4 RET token format, with no RET keys - which should fall back to Static)
        staticViewFull?.setToken(token:"eyJiIjoiMDg2NzM0NjQ3NjA0MTYxNmEiLCJydCI6ImJhcmNvZGUifQ==")
		
		// A small static PDF417 (missing RET token/keys) state
		staticViewNoToken?.setToken(token:"eyJiIjoiODMwNTM2NjY1MTU4ayIsInJ0Ijoicm90YXRpbmdfc3ltYm9sb2d5In0=", errorText:nil)
		
		// A large invalid (bad token) error state, with a longer error message
		staticViewInvalid?.setToken(token:"ABC123", errorText:"Custom user guidance can be entered here, 60 char max length")
		
		// A larger edge-to-edge custom error state, displaying an arbitrary error message within the view
		staticCustomError?.showError(text:"Custom error state, still bound by the same 60 character limit", icon:UIImage(named: "Static"))
    }
}


