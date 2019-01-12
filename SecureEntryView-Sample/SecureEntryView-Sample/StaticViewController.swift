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
        staticView?.setToken(token:"eyJiIjogIjE5NzM3OTA2OTQzNDc3OTlhIiwidCI6ICIiLCJjayI6ICIiLCAiZWsiOiAiIn0=")
        staticViewSized?.setToken(token:"eyJiIjogIjE5NzM3OTA2OTQzNDc3OTlhIiwidCI6ICIiLCJjayI6ICIiLCAiZWsiOiAiIn0=")
        staticViewFull?.setToken(token:"eyJiIjogIjE5NzM3OTA2OTQzNDc3OTlhIiwidCI6ICIiLCJjayI6ICIiLCAiZWsiOiAiIn0=")
        
        staticViewNoToken?.setToken(token:nil)
        
        staticViewInvalid?.setToken(token:"ABC123")
    }
}


