//
//  TipoDocumentoModel.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 10/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation
import ObjectMapper

class TipoDocumentoModel: Model {
    
    var nome: String!
    var ordem: Int!
    var isObrigatorio: Bool!
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        nome <- map["nome"]
        ordem <- map["ordem"]
        isObrigatorio <- map["obrigatorio"]
    }
}
