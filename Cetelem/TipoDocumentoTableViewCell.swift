//
//  TipoDocumentoTableViewCell.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 17/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit

class TipoDocumentoTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
}

extension TipoDocumentoTableViewCell {
    
    func prepare(_ model: TipoDocumentoModel) {
        ViewUtils.text(model.nome, for: label)
    }
}
