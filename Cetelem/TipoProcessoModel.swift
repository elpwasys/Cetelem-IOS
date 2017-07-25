//
//  TipoProcessoModel.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 09/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation
import ObjectMapper

class TipoProcessoModel: Model {
    
    var nome: String!
    
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
        return values
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        nome <- map["nome"]
    }
}

extension TipoProcessoModel: Selectable {
    
    var value: String {
        return "\(id!)"
    }
    
    var label: String {
        return nome
    }
}
