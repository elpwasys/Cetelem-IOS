//
//  TextFieldTableViewCell.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 23/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit

class TextFieldTableViewCell: CampoTableViewCell {
    
    @IBOutlet weak var textField: MaterialTextField!
    
    fileprivate var campo: CampoModel?
    
    override var value: String? {
        return textField.text
    }
    
    override var isEnabled: Bool {
        didSet {
            if textField != nil {
                textField.isEnabled = isEnabled
            }
        }
    }
    
    override var isValid: Bool {
        if let campo = self.campo, let name = TextUtils.capitalize(campo.nome) {
            let value = textField.text
            textField.error = nil
            if TextUtils.isBlank(value) {
                let messageText = TextUtils.localized(forKey: "Label.CampoObrigatorio")
                textField.error = "\(name) \(messageText)"
                return false
            }
            let length = value?.characters.count ?? 0
            if let minLength = campo.tamanhoMinimo, length < minLength {
                let messageText = TextUtils.localized(forKey: "Message.CampoInvalidoMinLength")
                textField.error = "\(name) \(messageText) \(minLength)"
                return false
            }
            if let maxLength = campo.tamanhoMaximo, length > maxLength {
                let messageText = TextUtils.localized(forKey: "Message.CampoInvalidoMaxLength")
                textField.error = "\(name) \(messageText) \(maxLength)"
                return false
            }
        } else {
            return false
        }
        return true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.labelNormalColor = Color.grey500
        textField.labelActiveColor = Color.primary
        textField.dividerNormalColor = Color.grey500
        textField.dividerActiveColor = Color.primary
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepare(_ model: CampoModel) {
        self.clear()
        self.campo = model
        textField.isEnabled = isEnabled
        textField.placeholder = TextUtils.capitalize(model.nome)
        ViewUtils.text(model.valor, for: textField)
        if model.tipo == .inteiro {
            textField.keyboardType = .numberPad
        }
    }
}

extension TextFieldTableViewCell {
    
    static var height: CGFloat {
        return 86
    }
    
    static var nibName: String {
        return "\(TextFieldTableViewCell.self)"
    }
    
    static var reusableCellIdentifier: String {
        return "\(TextFieldTableViewCell.self)"
    }
    
    fileprivate func clear() {
        textField.error = nil
    }
}
