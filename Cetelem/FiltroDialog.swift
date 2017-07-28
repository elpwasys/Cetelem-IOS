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
    
    @IBOutlet weak var numeroTextField: AppTextField!
    @IBOutlet weak var dataInicioTextField: AppDateField!
    @IBOutlet weak var dataTerminoTextField: AppDateField!
    @IBOutlet weak var tipoProcessoPickerField: AppPickerField!
    @IBOutlet weak var statusProcessoPickerField: AppPickerField!
    
    var completionHandler: ((FiltroModel) -> Void)?
    
    @IBAction func onLimparPressed() {
        if let completionHandler = self.completionHandler {
            let filtro = FiltroModel()
            completionHandler(filtro)
        }
    }
    
    @IBAction func onFiltrarPressed() {
        if let completionHandler = self.completionHandler {
            let filtro = FiltroModel()
            if TextUtils.isNotBlank(numeroTextField.text) {
                filtro.numero = numeroTextField.text
            }
            filtro.dataInicio = dataInicioTextField.date
            filtro.dataTermino = dataTerminoTextField.date
            if let option = tipoProcessoPickerField.value {
                filtro.tipoProcessoId = Int(option.value)
            }
            if let option = statusProcessoPickerField.value {
                filtro.status = ProcessoModel.Status(rawValue: option.value)
            }
            completionHandler(filtro)
        }
    }
}

extension FiltroDialog {
    
    static func create(filtro: FiltroModel?, meta: ProcessoMeta?, view: UIView) -> FiltroDialog {
        
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
        
        if let entries = meta?.tiposProcessos {
            dialog.tipoProcessoPickerField.entries(array: entries)
        }
        
        dialog.statusProcessoPickerField.entries(array: ProcessoModel.Status.values)
        
        if let model = filtro {
            ViewUtils.text(model.numero, for: dialog.numeroTextField)
            ViewUtils.text(model.dataInicio, for: dialog.dataInicioTextField)
            ViewUtils.text(model.dataTermino, for: dialog.dataTerminoTextField)
            dialog.statusProcessoPickerField.value = model.status
            if let entries = meta?.tiposProcessos {
                for entry in entries {
                    if entry.id == model.tipoProcessoId {
                        dialog.statusProcessoPickerField.value = entry
                        break
                    }
                }
            }
        }
        
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
        numeroTextField.borderWidth = 1
        numeroTextField.borderColor = Color.grey500
    }
     
    fileprivate func preparePeriodoInicioTextField() {
        dataInicioTextField.borderWidth = 1
        //dataInicioTextField.leftImage = Icon.dateRange
        dataInicioTextField.borderColor = Color.grey500
    }
     
    fileprivate func preparePeriodoTerminoTextField() {
        dataTerminoTextField.borderWidth = 1
        //dataTerminoTextField.leftImage = Icon.dateRange
        dataTerminoTextField.borderColor = Color.grey500
    }
     
    fileprivate func prepareTipoProcessoPickerField() {
        tipoProcessoPickerField.borderWidth = 1
        tipoProcessoPickerField.borderColor = Color.grey500
    }
    
    fileprivate func prepareStatusProcessoPickerField() {
        statusProcessoPickerField.borderWidth = 1
        statusProcessoPickerField.borderColor = Color.grey500
    }
}
