//
//  DocumentoTableViewCell.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 17/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit

class DocumentoTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
}

extension DocumentoTableViewCell {
    
    func prepare(_ model: TipoDocumentoModel) {
        ViewUtils.text(model.nome, for: label)
    }
}
