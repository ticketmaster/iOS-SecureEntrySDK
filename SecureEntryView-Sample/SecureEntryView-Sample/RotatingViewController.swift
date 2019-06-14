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
    
    @IBOutlet weak var retView: Presence.SecureEntryView?
    @IBOutlet weak var retViewSized: Presence.SecureEntryView?
    @IBOutlet weak var retViewFull: Presence.SecureEntryView?
    @IBOutlet weak var retViewNoToken: Presence.SecureEntryView?
    @IBOutlet weak var retViewInvalid: Presence.SecureEntryView?
	@IBOutlet weak var retViewUnloaded: Presence.SecureEntryView?
    @IBOutlet weak var retViewNoText: Presence.SecureEntryView?
    @IBOutlet weak var retViewBrandedText: Presence.SecureEntryView?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Pre-sync time, for Rotating Entry
		SecureEntryView.syncTime()
	}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let v3token = "eyJiIjoiOTY0NTM3MjgzNDIxIiwidCI6IlRNOjowMzo6MjAxeXRmbmllN2tpZmxzZ2hncHQ5ZDR4N2JudTljaG4zYWNwdzdocjdkOWZzc3MxcyIsImNrIjoiMzRkNmQyNTNiYjNkZTIxOTFlZDkzMGY2MmFkOGQ0ZDM4NGVhZTVmNSJ9"
        let v4token = "eyJiIjoiMDg2NzM0NjQ3NjA0MTYxNmEiLCJ0IjoiQkFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFDR2tmNWxkZWZ3WEh3WmpvRmMzcnNEY0RINkpyY2pqOW0yS0liKyIsImNrIjoiNjhhZjY5YTQtZjlhNi00ZTRhLTkxZmEtNDYwYmRhMTdmNDI3IiwiZWsiOiIwNmVjNTNjNy00OWU0LTQ3YTQtODgwMi01N2Y3M2RjM2FiZmMiLCJydCI6InJvdGF0aW5nX3N5bWJvbG9neSJ9"
		
		// Standard view, rendered at the minimum size (216x160) (using simple V3 token)
        retView?.setToken(token: v3token)
		
		// Scaled view, with a custom programatically controlled branding color (using V3 token)
        retViewSized?.setToken(token: v3token)
        retViewSized?.setBrandingColor(color: UIColor.green)
		
		// Large view, rendered edge-to-edge (using v4 token)
        retViewFull?.setToken(token: v4token)
		
		// An invalid (no token) error state, with a short error message
		retViewNoToken?.setToken(token:nil, errorText:"Reload ticket")
		
		// A small invalid (bad token) error state, with a longer error message
		retViewInvalid?.setToken(token:"ABC123", errorText:"Custom user guidance can be entered here, 60 char max length")
       
        // Scaled View, with no subtitle values for pdf417 or qr.
        retViewNoText?.setToken(token: v3token)
        retViewNoText?.setPdf417Subtitle(subtitleText: "")
        retViewNoText?.setQrCodeSubtitle(subtitleText: "")
        
        // Scaled View, with branded subtitle values for pdf417 or qr.
        retViewBrandedText?.setToken(token: v4token)
        retViewBrandedText?.setBrandingColor(color: UIColor.red)
        retViewBrandedText?.enableBrandedSubtitle(enable: true)
    }
}
