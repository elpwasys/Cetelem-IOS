//
//  DrawerViewController.swift
//  NavigationDrawer
//
//  Created by Everton Luiz Pascke on 18/10/16.
//  Copyright © 2016 Everton Luiz Pascke. All rights reserved.
//

import UIKit

class DrawerViewController: CetelemViewController {
    
    private var drawerButton: UIBarButtonItem!
    
    var isLeftMenu = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareDrawer()
    }
    
    fileprivate func prepareDrawer() {
        if isLeftMenu {
            if let controller = revealViewController() {
                controller.delegate = self
                drawerButton = UIBarButtonItem(image: Icon.menu, style: .plain, target: nil, action: nil)
                drawerButton.target = controller
                drawerButton.action = #selector(SWRevealViewController.revealToggle(_:))
                navigationItem.setLeftBarButton(drawerButton, animated: true)
                view.addGestureRecognizer(controller.panGestureRecognizer())
                view.addGestureRecognizer(controller.tapGestureRecognizer())
            }
        }
    }
    
    override func showActivityIndicator() {
        if let controller = revealViewController() {
            App.Loading.shared.show(view: controller.view)
        } else {
            super.showActivityIndicator()
        }
    }
}

extension DrawerViewController: SWRevealViewControllerDelegate {
    func revealController(_ revealController: SWRevealViewController!, willMoveTo position: FrontViewPosition) {
        
    }
}
