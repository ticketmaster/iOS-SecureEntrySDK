//
//  AppDelegate.swift
//  SecureEntryView-Sample
//
//  Created by Karl White on 1/8/19.
//  Copyright © 2019 Ticketmaster. All rights reserved.
//

import UIKit
import Presence

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
  {
    SecureEntryView.syncTime()
    return true
	}
}

