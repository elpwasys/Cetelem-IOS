//
//  AlertDialogViewController.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 25/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit

class AlertDialogViewController: UIViewController {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    
    @IBOutlet weak var negativeButton: UIButton!
    @IBOutlet weak var positiveButton: UIButton!
    
    var completionHandler: ((Bool) -> Void)?
    
    var message: String? {
        didSet {
            preapareMessage()
        }
    }
    
    var positiveText: String? {
        didSet {
            preparePositiveButton()
        }
    }
    
    var negativeText: String? {
        didSet {
            prepareNegativeButton()
        }
    }
    
    override var title: String? {
        didSet {
            preapareTitle()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepare()
    }
    
    
    @IBAction func onNegativePressed() {
        if let completionHandler = self.completionHandler {
            completionHandler(false)
        }
    }
    
    @IBAction func onPositivePressed() {
        if let completionHandler = self.completionHandler {
            completionHandler(true)
        }
    }
}

extension AlertDialogViewController {
    
    fileprivate func prepare() {
        preapareTitle()
        preapareMessage()
        prepareNegativeButton()
        preparePositiveButton()
        ShadowUtils.applyBottom(topView)
        ShadowUtils.applyTop(bottomView)
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
    }
    
    fileprivate func preapareTitle() {
        if titleLabel != nil {
            ViewUtils.text(title, for: titleLabel)
        }
    }
    
    fileprivate func preapareMessage() {
        if messageTextView != nil {
            ViewUtils.text(message, for: messageTextView)
        }
    }
    
    fileprivate func prepareNegativeButton() {
        if negativeButton != nil {
            var title = TextUtils.localized(forKey: "Label.Nao")
            if let text = self.negativeText {
                title = text
            }
            negativeButton.setTitle(title, for: .normal)
        }
    }
    
    fileprivate func preparePositiveButton() {
        if positiveButton != nil {
            var title = TextUtils.localized(forKey: "Label.Sim")
            if let text = self.positiveText {
                title = text
            }
            positiveButton.setTitle(title, for: .normal)
        }
    }
}
