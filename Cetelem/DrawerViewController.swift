//
//  DrawerViewController.swift
//  NavigationDrawer
//
//  Created by Everton Luiz Pascke on 18/10/16.
//  Copyright © 2016 Everton Luiz Pascke. All rights reserved.
//

import UIKit

class DrawerViewController: CetelemViewController {
    
    fileprivate var overlay: UIView!
    fileprivate var drawerButton: UIBarButtonItem!
    
    var isLeftMenu = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareDrawer()
        prepareOverlay()
    }
    
    fileprivate func prepareOverlay() {
        if overlay == nil {
            overlay = UIView()
            overlay.frame = view.frame
            overlay.center = view.center
            overlay.alpha = 0.5
            overlay.backgroundColor = UIColor.black
            overlay.clipsToBounds = true
        }
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
}

extension DrawerViewController: SWRevealViewControllerDelegate {
    func revealController(_ revealController: SWRevealViewController!, willMoveTo position: FrontViewPosition) {
        if position == .right {
            view.endEditing(true)
            view.addSubview(overlay)
        } else {
            overlay.removeFromSuperview()
        }
    }
}
