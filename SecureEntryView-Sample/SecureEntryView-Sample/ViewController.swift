//
//  ViewController.swift
//  SecureEntryView-Sample
//
//  Created by Karl White on 1/8/19.
//  Copyright © 2019 Ticketmaster. All rights reserved.
//

import UIKit
import Presence

class ViewController: UIViewController {

	@IBOutlet weak var secureEntryView: Presence.SecureEntryView?
	
	override func viewDidLoad() {
		super.viewDidLoad()
	secureEntryView?.setToken(token:"eyJiIjoiNzgxOTQxNjAzMDAxIiwidCI6IlRNOjowMzo6MjAxeXRmbmllN2tpZmxzZ2hncHQ5ZDR4N2JudTljaG4zYWNwdzdocjdkOWZzc3MxcyIsImNrIjoiMzRkNmQyNTNiYjNkZTIxOTFlZDkzMGY2MmFkOGQ0ZDM4NGVhZTVmNSJ9")
	}
}

