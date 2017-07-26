//
//  DocumentoTableViewCell.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 26/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit

class DocumentoTableViewCell: UITableViewCell {

    @IBOutlet weak var tituloLabel: UILabel!
}

extension DocumentoTableViewCell {
    
    static var nibName: String {
        return "\(DocumentoTableViewCell.self)"
    }
    
    static var reusableCellIdentifier: String {
        return "\(DocumentoTableViewCell.self)"
    }
    
    func prepare(_ model: DocumentoModel) {
        ViewUtils.text(model.nome, for: tituloLabel)
    }
}
