//
//  ProcessoTableViewCell.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 10/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit

class ProcessoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var tipoLabel: UILabel!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func populate(_ model: ProcessoModel) {
        ViewUtils.text(model.id, for: idLabel)
        ViewUtils.text(model.dataCriacao, for: dataLabel)
        ViewUtils.text(model.status.label, for: statusLabel)
        ViewUtils.text(model.tipoProcesso.nome, for: tipoLabel)
        statusImageView.image = model.status.icon
    }
}
