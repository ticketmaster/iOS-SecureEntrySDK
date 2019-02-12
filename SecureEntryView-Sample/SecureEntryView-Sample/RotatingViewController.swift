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
		
		// Standard view, rendered at the minimum size (216x160)
        retView?.setToken(token:"eyJiIjoiOTY0NTM3MjgzNDIxIiwidCI6IlRNOjowMzo6MjAxeXRmbmllN2tpZmxzZ2hncHQ5ZDR4N2JudTljaG4zYWNwdzdocjdkOWZzc3MxcyIsImNrIjoiMzRkNmQyNTNiYjNkZTIxOTFlZDkzMGY2MmFkOGQ0ZDM4NGVhZTVmNSJ9")
		
		// Scaled view, with a custom programatically controlled branding color
        retViewSized?.setToken(token:"eyJiIjoiOTY0NTM3MjgzNDIxIiwidCI6IlRNOjowMzo6MjAxeXRmbmllN2tpZmxzZ2hncHQ5ZDR4N2JudTljaG4zYWNwdzdocjdkOWZzc3MxcyIsImNrIjoiMzRkNmQyNTNiYjNkZTIxOTFlZDkzMGY2MmFkOGQ0ZDM4NGVhZTVmNSJ9")
        retViewSized?.setBrandingColor(color: UIColor.green)
		
		// Large view, rendered edge-to-edge
        retViewFull?.setToken(token:"eyJiIjoiOTY0NTM3MjgzNDIxIiwidCI6IlRNOjowMzo6MjAxeXRmbmllN2tpZmxzZ2hncHQ5ZDR4N2JudTljaG4zYWNwdzdocjdkOWZzc3MxcyIsImNrIjoiMzRkNmQyNTNiYjNkZTIxOTFlZDkzMGY2MmFkOGQ0ZDM4NGVhZTVmNSJ9")
		
		// An invalid (no token) error state, with a short error message
        retViewNoToken?.setToken(token:nil)
		retViewNoToken?.setErrorText(text:"Reload ticket")
		
		// A small invalid (bad token) error state, with a longer error message
        retViewInvalid?.setToken(token:"ABC123")
		retViewInvalid?.setErrorText(text:"Custom user guidance can be entered here, 60 char max length")
    }
}

