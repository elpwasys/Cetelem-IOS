//
//  FiltroDialog.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 26/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit

class FiltroDialog: View {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    
    fileprivate var view: UIView!
    fileprivate var overlay: UIView!
    
    @IBOutlet weak var numeroTextField: MaterialTextField!
    @IBOutlet weak var tipoProcessoPickerField: PickerField!
    @IBOutlet weak var statusProcessoPickerField: PickerField!
    
    var completionHandler: ((Bool) -> Void)?
}

extension FiltroDialog {
    
    static func create(view: UIView) -> FiltroDialog {
        
        let dialog = Bundle.main.loadNibNamed("FiltroDialog", owner: view, options: nil)?.first as! FiltroDialog
        dialog.prepare()
        
        dialog.frame.size = CGSize(width: view.frame.width - CGFloat(32), height: dialog.frame.height)
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
    
    func show() {
        if overlay == nil {
            
            let size = CGSize(width: self.frame.size.width, height: self.frame.size.height + CGFloat(32))

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
        ShadowUtils.applyBottom(topView)
        bottomView.borderTopWith(color: Color.grey300, width: 1)
        prepareNumeroTextField()
        preparePeriodoInicioTextField()
        preparePeriodoTerminoTextField()
        prepareTipoProcessoPickerField()
        prepareStatusProcessoPickerField()
    }
    
    fileprivate func prepareNumeroTextField() {
        numeroTextField.labelNormalColor = Color.grey500
        numeroTextField.labelActiveColor = Color.primary
        numeroTextField.dividerNormalColor = Color.grey500
        numeroTextField.dividerActiveColor = Color.primary
    }
    
    fileprivate func preparePeriodoInicioTextField() {
//        loginTextField.leftImage = Icon.person
//        loginTextField.labelNormalColor = Color.grey500
//        loginTextField.labelActiveColor = Color.primary
//        loginTextField.dividerNormalColor = Color.grey500
//        loginTextField.dividerActiveColor = Color.primary
    }
    
    fileprivate func preparePeriodoTerminoTextField() {
//        loginTextField.leftImage = Icon.person
//        loginTextField.labelNormalColor = Color.grey500
//        loginTextField.labelActiveColor = Color.primary
//        loginTextField.dividerNormalColor = Color.grey500
//        loginTextField.dividerActiveColor = Color.primary
    }
    
    fileprivate func prepareTipoProcessoPickerField() {
        tipoProcessoPickerField.rightImage = Icon.arrowDropDown
        tipoProcessoPickerField.labelNormalColor = Color.grey500
        tipoProcessoPickerField.labelActiveColor = Color.primary
        tipoProcessoPickerField.dividerNormalColor = Color.grey500
        tipoProcessoPickerField.dividerActiveColor = Color.primary
    }
    
    fileprivate func prepareStatusProcessoPickerField() {
        statusProcessoPickerField.rightImage = Icon.arrowDropDown
        statusProcessoPickerField.labelNormalColor = Color.grey500
        statusProcessoPickerField.labelActiveColor = Color.primary
        statusProcessoPickerField.dividerNormalColor = Color.grey500
        statusProcessoPickerField.dividerActiveColor = Color.primary
    }
}
