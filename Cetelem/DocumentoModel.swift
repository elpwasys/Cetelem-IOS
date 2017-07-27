//
//  DocumentoModel.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 26/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation
import ObjectMapper

class DocumentoModel: Model {
    
    var nome: String!
    var status: Status!
    var versaoAtual: Int!
    var qtdeImagens: Int?
    var dataDigitalizacao: Date?
    
    var obrigatorio = false
    var podeExcluir = false
    var justificavel = false
    var digitalizavel = false
    
    var irregularidadeNome: String?
    var pendenciaObservacao: String?
    var pendenciaJustificativa: String?
    
    var imagens: [ImagemModel]?
    
    enum Status: String {
        case incluido = "INCLUIDO"
        case pendente = "PENDENTE"
        case aprovado = "APROVADO"
        case processando = "PROCESSANDO"
        case digitalizado = "DIGITALIZADO"
        var key: String {
            return "Documento.Status.\(self)"
        }
        var icon: UIImage? {
            return UIImage(named: key)
        }
        var label: String {
            return TextUtils.localized(forKey: key)
        }
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        let dateTransform = DateTransformType()
        nome <- map["nome"]
        status <- map["status"]
        versaoAtual <- map["versaoAtual"]
        qtdeImagens <- map["qtdeImagens"]
        dataDigitalizacao <- (map["dataDigitalizacao"], dateTransform)
        obrigatorio <- map["obrigatorio"]
        podeExcluir <- map["podeExcluir"]
        justificavel <- map["justificavel"]
        digitalizavel <- map["digitalizavel"]
        irregularidadeNome <- map["irregularidadeNome"]
        pendenciaObservacao <- map["pendenciaObservacao"]
        pendenciaJustificativa <- map["pendenciaJustificativa"]
        imagens <- map["imagens"]
    }
}
