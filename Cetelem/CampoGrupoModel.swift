//
//  CampoGrupoModel.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 10/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation
import ObjectMapper

class CampoGrupoModel: Model {

    var nome: String!
    var ordem: Int!
    
    var campos: [CampoModel]?
    
    var dictionary: [String: Any]? {
        var values: [String: Any]?
        func put(_ key: String, _ value: Any?) {
            if value != nil, let text = TextUtils.text(value) {
                if values == nil {
                    values = [String: Any]()
                }
                values?[key] = text
            }
        }
        put("id", id)
        put("nome", nome)
        put("ordem", ordem)
        if let campos = self.campos {
            var elements = [[String: Any]]()
            for campo in campos {
                if let element = campo.dictionary {
                    elements.append(element)
                }
            }
            if !elements.isEmpty {
                if values == nil {
                    values = [String: String]()
                }
                values?["campos"] = elements
            }
        }
        return values
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        nome <- map["nome"]
        ordem <- map["ordem"]
        campos <- map["campos"]
    }
    
    func add(_ campo: CampoModel) {
        if self.campos == nil {
            self.campos = [CampoModel]()
        }
        self.campos?.append(campo)
    }
}
