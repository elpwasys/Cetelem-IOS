//
//  SwitchTableViewCell.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 11/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit

class SwitchTableViewCell: CampoTableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var control: UISwitch!
    
    fileprivate var campo: CampoModel?
    
    override var isEnabled: Bool {
        didSet {
            control.isEnabled = isEnabled
        }
    }
    
    override var value: String? {
        if let model = self.campo {
            if let opcoes = model.opcoes?.components(separatedBy: ","), opcoes.count == 2 {
                if control.isOn {
                    let expression = "(?i)sim"
                    if opcoes[0].folding(options: .diacriticInsensitive, locale: .current).range(of: expression, options: .regularExpression) != nil {
                        return opcoes[0]
                    } else if opcoes[1].folding(options: .diacriticInsensitive, locale: .current).range(of: expression, options: .regularExpression) != nil {
                        return opcoes[1]
                    }
                } else {
                    let expression = "(?i)nao"
                    if opcoes[0].folding(options: .diacriticInsensitive, locale: .current).range(of: expression, options: .regularExpression) != nil {
                        return opcoes[0]
                    } else if opcoes[1].folding(options: .diacriticInsensitive, locale: .current).range(of: expression, options: .regularExpression) != nil {
                        return opcoes[1]
                    }
                }
            }
        }
        return nil
    }
    
    override func awakeFromNib() {        
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepare(_ model: CampoModel) {
        self.campo = model
        ViewUtils.text(TextUtils.capitalize(model.nome), for: label)
        label.textColor = Color.grey500
        control.isEnabled = isEnabled
        var isOn = false
        if let valor = model.valor {
            isOn = valor.range(of: "(?i)sim", options: .regularExpression) != nil
        }
        control.isOn = isOn
    }
}

extension SwitchTableViewCell {
    
    static var height: CGFloat {
        return 63
    }
    
    static var nibName: String {
        return "\(SwitchTableViewCell.self)"
    }
    
    static var reusableCellIdentifier: String {
        return "\(SwitchTableViewCell.self)"
    }
    
    static func isSwitch(_ text: String?) -> Bool {
        guard var options = text, !options.isEmpty else {
            return false
        }
        options = options.folding(options: .diacriticInsensitive, locale: .current)
        guard options.range(of: "((?i)(sim,nao)|(nao,sim))", options: .regularExpression) != nil else {
            return false
        }
        return true
    }
}
