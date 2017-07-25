//
//  StartViewController.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 07/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit

class StartViewController: CetelemViewController {

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigate()
    }

    private func navigate() {
        let controller: UIViewController
        if Dispositivo.current != nil {
            controller = UIStoryboard.viewController("Menu", identifier: "Scene.Reveal")
        } else {
            controller = UIStoryboard.viewController("Main", identifier: "Scene.Login")
        }
        self.present(controller, animated: false, completion: nil)
    }
}
