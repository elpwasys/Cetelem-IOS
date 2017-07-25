//
//  RadioTableViewCell.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 12/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit

class RadioTableViewCell: CampoTableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var radioGroupView: UIView!
    
    fileprivate var campo: CampoModel?
    
    override var value: String? {
        guard let campo = self.campo else {
            return nil
        }
        if let opcoes = campo.opcoes?.components(separatedBy: ",") {
            for view in radioGroupView.subviews {
                if let radio = view as? RadioButton {
                    if radio.isSelected {
                        return opcoes[radio.tag]
                    }
                }
            }
        }
        return nil
    }
    
    override var isValid: Bool {
        var valid = false
        for view in radioGroupView.subviews {
            if let radio = view as? RadioButton {
                if radio.isSelected {
                    valid = true
                    break
                }
            }
        }
        detail.text = nil
        let requiredText = TextUtils.localized(forKey: "Label.CampoObrigatorio")
        if !valid {
            detail.text = "\(title.text!) \(requiredText)"
        }
        return valid
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        detail.textColor = Color.red500
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepare(_ model: CampoModel) {
        self.campo = model
        ViewUtils.text(TextUtils.capitalize(model.nome), for: title)
        for view in radioGroupView.subviews {
            view.removeFromSuperview()
        }
        if let opcoes = model.opcoes?.components(separatedBy: ",") {
            let size = RadioTableViewCell.size
            let padding = RadioTableViewCell.padding
            for (index, opcao) in opcoes.enumerated() {
                let y = (size + padding) * CGFloat(index)
                // RADIO
                let radio = RadioButton(frame: CGRect(x: 0, y: y, width: size, height: size))
                radio.tag = index
                radio.outerCircleColor = Color.grey500
                radio.addTarget(self, action: #selector(onRadioSelected(_:)), for: .touchUpInside)
                radioGroupView.addSubview(radio)
                // LABEL
                let label = UILabel(frame: CGRect(x: CGFloat(size + 16), y: y, width: radioGroupView.frame.size.width, height: CGFloat(size)))
                label.text = TextUtils.capitalize(opcao)
                label.font = self.title.font
                label.textColor = Color.grey500
                radioGroupView.addSubview(label)
            }
        }
    }
}

extension RadioTableViewCell {
    
    static var height: CGFloat {
        return 56
    }
    
    static var size: CGFloat {
        return 24
    }
    
    static var padding: CGFloat {
        return 8
    }
    
    static var nibName: String {
        return "\(RadioTableViewCell.self)"
    }
    
    static var reusableCellIdentifier: String {
        return "\(RadioTableViewCell.self)"
    }
    
    static func height(count: Int) -> CGFloat {
        let cg = CGFloat(count)
        return height + (cg * padding) + (cg * size)
    }
    
    @objc fileprivate func onRadioSelected(_ sender: RadioButton) {
        for view in radioGroupView.subviews {
            if let radio = view as? RadioButton {
                radio.isSelected = false
                radio.outerCircleColor = Color.grey500
            }
        }
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            sender.outerCircleColor = Color.accent
        }
    }
}
