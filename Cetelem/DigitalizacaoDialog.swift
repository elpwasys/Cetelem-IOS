//
//  DigitalizacaoDialog.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 26/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit

class DigitalizacaoDialog: View {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageTextView: UITextView!
    
    @IBOutlet weak var tipoLabel: UILabel!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mensagemLabel: Label!
    @IBOutlet weak var tentativaLabel: UILabel!
    @IBOutlet weak var referenciaLabel: UILabel!
    
    @IBOutlet weak var fecharButton: UIButton!
    @IBOutlet weak var reenviarButton: UIButton!
    
    var completionHandler: ((Bool) -> Void)?
    
    fileprivate var view: UIView!
    fileprivate var overlay: UIView!
    
    @IBAction func onFecharTapped() {
        if let completionHandler = self.completionHandler {
            completionHandler(false)
        }
    }
    
    @IBAction func onReenviarTapped() {
        if let completionHandler = self.completionHandler {
            completionHandler(true)
        }
    }
}

extension DigitalizacaoDialog {
    
    static func create(model: DigitalizacaoModel, view: UIView) -> DigitalizacaoDialog {
        
        let dialog = Bundle.main.loadNibNamed("DigitalizacaoDialog", owner: view, options: nil)?.first as! DigitalizacaoDialog
        dialog.prepare()
        
        let size: CGSize
        if TextUtils.isNotBlank(model.mensagem) {
            size = CGSize(width: view.frame.width - CGFloat(32), height: dialog.frame.height)
        } else {
            let height = dialog.mensagemLabel.frame.size.height + dialog.messageTextView.frame.size.height
            size = CGSize(width: view.frame.width - CGFloat(32), height: dialog.frame.size.height - height)
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
        dialog.titleLabel.textColor = model.status.textColor
        dialog.titleLabel.shadowColor = model.status.shadowColor
        dialog.topView.backgroundColor = model.status.backgroundColor
        ViewUtils.text(model.status.label, for: dialog.titleLabel)
        ViewUtils.text(model.tipo.label, for: dialog.tipoLabel)
        ViewUtils.text(model.referencia, for: dialog.referenciaLabel)
        ViewUtils.text(model.dataHora, for: dialog.dataLabel)
        ViewUtils.text(model.tentativas, for: dialog.tentativaLabel)
        ViewUtils.text(model.mensagem, for: dialog.messageTextView)
        if model.status == .erro {
            dialog.reenviarButton.isHidden = false
        }
        
        return dialog
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
        ShadowUtils.applyBottom(topView)
        bottomView.borderTopWith(color: Color.grey300, width: 1)
        let color = Color.grey400
        dataLabel.borderBottomWith(color: color, width: 1)
        tentativaLabel.borderBottomWith(color: color, width: 1)
        referenciaLabel.borderBottomWith(color: color, width: 1)
    }
}
