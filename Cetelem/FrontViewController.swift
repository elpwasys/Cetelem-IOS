//
//  FrontViewController.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 22/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit

class FrontViewController: DrawerViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let timing = UICubicTimingParameters(animationCurve: .easeIn)
        let animator = UIViewPropertyAnimator(duration: 0.5, timingParameters: timing)
        animator.addAnimations {
            self.imageView.alpha = 1
        }
        animator.addCompletion { _ in
            self.revealViewController().revealToggle(animated: true)
        }
        animator.startAnimation()
    }
}
