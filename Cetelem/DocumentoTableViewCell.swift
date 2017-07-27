//
//  DocumentoTableViewCell.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 26/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit

protocol DocumentoTableViewCellDelegate {
    
    func onJustificarTapped(cell: DocumentoTableViewCell)
}

class DocumentoTableViewCell: UITableViewCell {

    @IBOutlet weak var nomeLabel: UILabel!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var versaoLabel: UILabel!
    @IBOutlet weak var observacaoLabel: UILabel!
    @IBOutlet weak var irregularidadeLabel: UILabel!
    
    @IBOutlet weak var statusImage: UIImageView!
    
    @IBOutlet weak var pendenciaView: UIView!
    @IBOutlet weak var observacaoView: UIView!
    @IBOutlet weak var pendenciaViewHeightConstraint: NSLayoutConstraint!
    
    fileprivate var delegate: DocumentoTableViewCellDelegate!
    
    @IBAction func onUndoButtonTapped() {
        delegate.onJustificarTapped(cell: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        observacaoView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 4)
    }
}

extension DocumentoTableViewCell {
    
    static var totalHeight: CGFloat {
        return detalheHeight + pendenciaHeight
    }
    
    static var detalheHeight: CGFloat {
        return 96
    }
    
    static var pendenciaHeight: CGFloat {
        return 78
    }
    
    static var nibName: String {
        return "\(DocumentoTableViewCell.self)"
    }
    
    static var reusableCellIdentifier: String {
        return "\(DocumentoTableViewCell.self)"
    }
    
    func prepare(_ model: DocumentoModel, delegate: DocumentoTableViewCellDelegate) {
        self.delegate = delegate
        ViewUtils.text(model.nome, for: nomeLabel)
        ViewUtils.text(model.versaoAtual, for: versaoLabel)
        ViewUtils.text(model.status.label, for: statusLabel)
        ViewUtils.text(model.dataDigitalizacao, for: dataLabel)
        ViewUtils.text(model.irregularidadeNome, for: irregularidadeLabel)
        ViewUtils.text(model.pendenciaObservacao, for: observacaoLabel)
        statusImage.image = model.status.icon
        if model.status != .pendente {
            pendenciaView.isHidden = true
            pendenciaViewHeightConstraint.constant = 0
        } else {
            pendenciaView.isHidden = false
            pendenciaViewHeightConstraint.constant = DocumentoTableViewCell.pendenciaHeight
        }
    }
}
