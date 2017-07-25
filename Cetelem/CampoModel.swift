//
//  CampoModel.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 10/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation
import ObjectMapper

class CampoModel: Model {
    
    var tipo: Tipo!
    var nome: String!
    var ordem: Int!
    var isObrigatorio: Bool!
    
    var dica: String?
    var valor: String?
    var opcoes: String?
    var tamanhoMinimo: Int?
    var tamanhoMaximo: Int?
    
    var dictionary: [String: String]? {
        var values: [String: String]?
        func put(_ key: String, _ value: Any?) {
            if value != nil, let text = TextUtils.text(value) {
                if values == nil {
                    values = [String: String]()
                }
                values?[key] = text
            }
        }
        put("id", id)
        put("nome", nome)
        put("ordem", ordem)
        put("dica", dica)
        put("valor", valor)
        put("opcoes", opcoes)
        put("obrigatorio", isObrigatorio)
        put("tamanhoMinimo", tamanhoMinimo)
        put("tamanhoMaximo", tamanhoMaximo)
        if tipo != nil {
            put("tipo", tipo.rawValue)
        }
        return values
    }
    
    enum Tipo: String {
        case cep = "CEP"
        case cnpj = "CNPJ"
        case comboBox = "COMBO_BOX"
        case cpf = "CPF"
        case cpfCnpj = "CPF_CNPJ"
        case data = "DATA"
        case email = "EMAIL"
        case hora = "HORA"
        case inteiro = "INTEIRO"
        case moeda = "MOEDA"
        case placa = "PLACA"
        case radio = "RADIO"
        case telefone = "TELEFONE"
        case texto = "TEXTO"
        case textoLongo = "TEXTO_LONGO"
        case uf = "UF"
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        tipo <- map["tipo"]
        nome <- map["nome"]
        ordem <- map["ordem"]
        isObrigatorio <- map["obrigatorio"]
        dica <- map["dica"]
        valor <- map["valor"]
        opcoes <- map["opcoes"]
        tamanhoMinimo <- map["tamanhoMinimo"]
        tamanhoMaximo <- map["tamanhoMaximo"]
    }
}
