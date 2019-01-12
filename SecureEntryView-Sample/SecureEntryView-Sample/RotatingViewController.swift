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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        retView?.setToken(token:"eyJiIjoiOTY0NTM3MjgzNDIxIiwidCI6IlRNOjowMzo6MjAxeXRmbmllN2tpZmxzZ2hncHQ5ZDR4N2JudTljaG4zYWNwdzdocjdkOWZzc3MxcyIsImNrIjoiMzRkNmQyNTNiYjNkZTIxOTFlZDkzMGY2MmFkOGQ0ZDM4NGVhZTVmNSJ9")
        retViewSized?.setToken(token:"eyJiIjoiOTY0NTM3MjgzNDIxIiwidCI6IlRNOjowMzo6MjAxeXRmbmllN2tpZmxzZ2hncHQ5ZDR4N2JudTljaG4zYWNwdzdocjdkOWZzc3MxcyIsImNrIjoiMzRkNmQyNTNiYjNkZTIxOTFlZDkzMGY2MmFkOGQ0ZDM4NGVhZTVmNSJ9")
        retViewSized?.setBrandingColor(color: UIColor.green)
        retViewFull?.setToken(token:"eyJiIjoiOTY0NTM3MjgzNDIxIiwidCI6IlRNOjowMzo6MjAxeXRmbmllN2tpZmxzZ2hncHQ5ZDR4N2JudTljaG4zYWNwdzdocjdkOWZzc3MxcyIsImNrIjoiMzRkNmQyNTNiYjNkZTIxOTFlZDkzMGY2MmFkOGQ0ZDM4NGVhZTVmNSJ9")
        
        retViewNoToken?.setToken(token:nil)
        
        retViewInvalid?.setToken(token:"ABC123")
    }
}

