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
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Pre-sync time, for Rotating Entry
		SecureEntryView.syncTime()
	}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		
		// Standard view, rendered at the minimum size (216x160) (using simple V3 token)
        retView?.setToken(token:"eyJiIjoiOTY0NTM3MjgzNDIxIiwidCI6IlRNOjowMzo6MjAxeXRmbmllN2tpZmxzZ2hncHQ5ZDR4N2JudTljaG4zYWNwdzdocjdkOWZzc3MxcyIsImNrIjoiMzRkNmQyNTNiYjNkZTIxOTFlZDkzMGY2MmFkOGQ0ZDM4NGVhZTVmNSJ9")
		
		// Scaled view, with a custom programatically controlled branding color (using V3 token)
        retViewSized?.setToken(token:"eyJiIjoiODMwNTM2NjY1MTU4ayIsInQiOiJUTTo6MDM6OjIxN3F6MjE3MHUxbXA3M2szNnkyN2oxa2hjYWdkb2I0aXR1c2wwZ2l4ZjF1YTB2NTAiLCJjayI6ImIwNmYwZjZmZjg3NTBjYjc4NzVhYjI2MDRmMmM0OGI0MWM3OWQ4M2YiLCJydCI6InJvdGF0aW5nX3N5bWJvbG9neSJ9")
        retViewSized?.setBrandingColor(color: UIColor.green)
		
		// Large view, rendered edge-to-edge (using v4 token)
        retViewFull?.setToken(token:"eyJiIjoiMDg2NzM0NjQ3NjA0MTYxNmEiLCJ0IjoiQkFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFDR2tmNWxkZWZ3WEh3WmpvRmMzcnNEY0RINkpyY2pqOW0yS0liKyIsImNrIjoiNjhhZjY5YTQtZjlhNi00ZTRhLTkxZmEtNDYwYmRhMTdmNDI3IiwiZWsiOiIwNmVjNTNjNy00OWU0LTQ3YTQtODgwMi01N2Y3M2RjM2FiZmMiLCJydCI6InJvdGF0aW5nX3N5bWJvbG9neSJ9")
		
		// An invalid (no token) error state, with a short error message
		retViewNoToken?.setToken(token:nil, errorText:"Reload ticket")
		
		// A small invalid (bad token) error state, with a longer error message
		retViewInvalid?.setToken(token:"ABC123", errorText:"Custom user guidance can be entered here, 60 char max length")
    }
}

