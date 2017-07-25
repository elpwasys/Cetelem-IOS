//
//  DrawerViewController.swift
//  NavigationDrawer
//
//  Created by Everton Luiz Pascke on 18/10/16.
//  Copyright © 2016 Everton Luiz Pascke. All rights reserved.
//

import UIKit

class DrawerViewController: CetelemViewController {
    
    @IBOutlet weak var drawerButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if drawerButton != nil {
            if let controller = revealViewController() {
                view.addGestureRecognizer(controller.panGestureRecognizer())
                view.addGestureRecognizer(controller.tapGestureRecognizer())
                controller.delegate = self
                drawerButton.target = controller
                drawerButton.action = #selector(SWRevealViewController.revealToggle(_:))
            }
        }
    }
}

extension DrawerViewController: SWRevealViewControllerDelegate {
    
    func revealController(_ revealController: SWRevealViewController!, willMoveTo position: FrontViewPosition) {
        
    }
}
