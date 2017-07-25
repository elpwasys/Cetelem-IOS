//
//  AppDelegate.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 22/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        IQKeyboardManager.sharedManager().enable = true
        let color = Color.primary
        UITextField.appearance().tintColor = Color.grey600
        UINavigationBar.appearance().barTintColor = color
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().tintColor = Color.white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: Color.white]
        return true
    }
}

