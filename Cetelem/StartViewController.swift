//
//  StartViewController.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 07/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit

class StartViewController: CetelemViewController {

    @IBOutlet weak var imageView: UIImageView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let timing = UICubicTimingParameters(animationCurve: .easeOut)
        let animator = UIViewPropertyAnimator(duration: 0.5, timingParameters: timing)
        animator.addAnimations {
            self.imageView.alpha = 0
        }
        animator.addCompletion { _ in
            self.navigate()
        }
        animator.startAnimation()
    }

    private func navigate() {
        let controller: UIViewController
        if Dispositivo.current == nil {
            controller = UIStoryboard.viewController("Main", identifier: "Scene.Login")
        } else {
            controller = UIStoryboard.viewController("Menu", identifier: "Scene.Reveal")
            controller.modalTransitionStyle = .crossDissolve
        }
        self.present(controller, animated: true, completion: nil)
    }
}
