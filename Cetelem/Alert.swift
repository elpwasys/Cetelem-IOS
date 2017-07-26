//
//  Alert.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 25/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit

class Alert: View {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    
    @IBOutlet weak var negativeButton: UIButton!
    @IBOutlet weak var positiveButton: UIButton!
    
    var completionHandler: ((Bool) -> Void)?
    
    fileprivate var view: UIView!
    fileprivate var overlay: UIView!
    
    var title: String? {
        didSet {
            preapareTitle()
        }
    }
    
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

extension Alert {
    
    static func create(view: UIView) -> Alert {
        let alert = Bundle.main.loadNibNamed("Alert", owner: view, options: nil)?.first as! Alert
        alert.prepare()
        
        
        alert.frame.size = CGSize(width: view.frame.width - CGFloat(32), height: alert.frame.height)
        alert.view = view
        alert.cornerRadius = 4
        
        let layer = alert.layer
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        layer.shadowRadius = 4.0
        layer.shadowOpacity = 0.4
        layer.shadowPath = UIBezierPath(roundedRect: layer.bounds, cornerRadius: layer.cornerRadius).cgPath
        
        return alert
    }
    
    func show() {
        if overlay == nil {
            // TODO PENSAR EM UM JEITO MELHOR DE FAZER ISSO
            var size = CGSize(width: self.frame.size.width, height: self.frame.size.height + CGFloat(32))
            if messageTextView.contentSize.height > 32 {
                size = CGSize(width: self.frame.size.width, height: self.frame.size.height + messageTextView.contentSize.height)
            }
            
            self.frame.size = size
            
            // Overlay
            overlay = UIView(frame: view.frame)
            overlay.center = view.center
            overlay.alpha = 0.5
            overlay.backgroundColor = UIColor.black
            
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hide))
            overlay.addGestureRecognizer(gestureRecognizer)
            
            center = overlay.center
            //
            view.addSubview(overlay)
            
            self.alpha = 0
            view.addSubview(self)
            
            let timing = UICubicTimingParameters(animationCurve: .easeIn)
            let animator = UIViewPropertyAnimator(duration: 0.25, timingParameters: timing)
            animator.addAnimations {
                self.alpha = 1
            }
            animator.startAnimation()
        }
    }
    
    func hide() {
        if overlay != nil {
            overlay.removeFromSuperview()
            overlay = nil
            self.removeFromSuperview()
        }
    }
    
    fileprivate func prepare() {
        preapareTitle()
        preapareMessage()
        prepareNegativeButton()
        preparePositiveButton()
        ShadowUtils.applyBottom(topView)
        ShadowUtils.applyTop(bottomView)
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
