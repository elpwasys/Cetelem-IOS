//
//  CetelemViewController.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 22/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit
import MaterialComponents

class CetelemViewController: AppViewController {

    fileprivate var snackbar: MDCSnackbarMessage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let navigationBar = self.navigationController?.navigationBar {
            ShadowUtils.applyBottom(navigationBar)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        hideSnackbar()
        super.viewWillDisappear(animated)
    }
    
    override func showActivityIndicator() {
        if let controller = revealViewController() {
            App.Loading.shared.show(view: controller.view)
        } else {
            super.showActivityIndicator()
        }
    }
}

extension CetelemViewController {
    
    func hideSnackbar() {
        if let snackbar = self.snackbar {
            MDCSnackbarManager.dismissAndCallCompletionBlocks(withCategory: snackbar.category)
        }
    }
    
    func showSnackbar(title: String, message: String, handler: @escaping (() -> Void)) {
        hideSnackbar()
        if self.snackbar == nil {
            self.snackbar = MDCSnackbarMessage()
            self.snackbar!.category = "\(CetelemViewController.self)"
            self.snackbar!.buttonTextColor = Color.accent
        }
        let action = MDCSnackbarMessageAction()
        action.title = title
        action.handler = handler
        self.snackbar!.text = message
        self.snackbar!.action = action
        self.snackbar!.duration = 4
        MDCSnackbarManager.show(self.snackbar!)
    }
}
