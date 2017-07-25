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

    override func viewDidLoad() {
        super.viewDidLoad()
        if let navigationBar = self.navigationController?.navigationBar {
            ShadowUtils.applyBottom(navigationBar)
        }
    }
}
