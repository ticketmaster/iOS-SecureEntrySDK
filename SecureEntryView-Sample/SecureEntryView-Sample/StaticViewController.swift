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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		
		// Standard view, rendered at the minimum size (216x160)
        staticView?.setToken(token:"eyJiIjogIjE5NzM3OTA2OTQzNDc3OTlhIiwidCI6ICIiLCJjayI6ICIiLCAiZWsiOiAiIn0=")
		
		// Scaled view
        staticViewSized?.setToken(token:"eyJiIjogIjE5NzM3OTA2OTQzNDc3OTlhIiwidCI6ICIiLCJjayI6ICIiLCAiZWsiOiAiIn0=")
		
		// Large view, rendered edge-to-edge
        staticViewFull?.setToken(token:"eyJiIjogIjE5NzM3OTA2OTQzNDc3OTlhIiwidCI6ICIiLCJjayI6ICIiLCAiZWsiOiAiIn0=")
		
		// A small invalid (no token) error state, with no error message
        staticViewNoToken?.setToken(token:nil)
		staticViewNoToken?.setErrorText(text:nil)
		
		// A larger invalid (bad token) error state, with a longer error message
        staticViewInvalid?.setToken(token:"ABC123")
		staticViewInvalid?.setErrorText(text:"Custom user guidance can be entered here, 60 char max length")
    }
}


