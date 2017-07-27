//
//  PendenciaDialog.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 26/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit

class PendenciaDialog: View {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var observacaoTextView: UITextView!
    @IBOutlet weak var justificativaTextView: UITextView!
    
    @IBOutlet weak var observacaoTextViewHeightConstraint: NSLayoutConstraint!
    
    var completionHandler: ((Bool, String?) -> Void)?
    
    fileprivate var view: UIView!
    fileprivate var overlay: UIView!
    
    @IBAction func onFecharTapped() {
        if let completionHandler = self.completionHandler {
            completionHandler(false, nil)
        }
    }
    
    @IBAction func onJustificarTapped() {
        if validate() {
            if let completionHandler = self.completionHandler {
                let text = justificativaTextView.text
                completionHandler(true, text)
            }
        }
    }
}

extension PendenciaDialog {
    
    fileprivate func validate() -> Bool {
        var valid = true;
        let requiredText = TextUtils.localized(forKey: "Label.CampoObrigatorio")
        errorLabel.text = nil
        if TextUtils.isBlank(justificativaTextView.text) {
            let label = TextUtils.localized(forKey: "Label.Justificativa")
            errorLabel.text = "\(label) \(requiredText)"
            valid = false
        }
        return valid
    }
    
    static func create(model: DocumentoModel, view: UIView) -> PendenciaDialog {
        
        let dialog = Bundle.main.loadNibNamed("PendenciaDialog", owner: view, options: nil)?.first as! PendenciaDialog
        dialog.prepare()
        
        ViewUtils.text(model.irregularidadeNome, for: dialog.titleLabel)
        ViewUtils.text(model.pendenciaObservacao, for: dialog.observacaoTextView)
        
        var size = CGSize(width: view.frame.width - CGFloat(32), height: dialog.frame.height)
        let sizeHeight = dialog.observacaoTextView.frame.size.height
        let contentSizeHeight = dialog.observacaoTextView.contentSize.height
        if sizeHeight < contentSizeHeight {
            dialog.observacaoTextViewHeightConstraint.constant = contentSizeHeight
            size = CGSize(width: view.frame.width - CGFloat(32), height: dialog.frame.height - sizeHeight + contentSizeHeight)
        }
        
        dialog.frame.size = size
        
        dialog.view = view
        dialog.cornerRadius = 4
        
        let layer = dialog.layer
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        layer.shadowRadius = 4.0
        layer.shadowOpacity = 0.4
        layer.shadowPath = UIBezierPath(roundedRect: layer.bounds, cornerRadius: layer.cornerRadius).cgPath
        
        return dialog
    }
    
    fileprivate func prepare() {
        ShadowUtils.applyBottom(topView)
        bottomView.borderTopWith(color: Color.grey300, width: 1)
    }
    
    func show() {
        if overlay == nil {
            
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
            animator.addCompletion({ _ in
                self.justificativaTextView.becomeFirstResponder()
            })
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
}
