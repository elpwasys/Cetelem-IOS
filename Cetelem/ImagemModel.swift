//
//  ImagemModel.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 26/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation
import ObjectMapper

class ImagemModel: Model {
    
    var path: String?
    
    var versao: Int!
    var caminho: String!
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        versao <- map["versao"]
        caminho <- map["caminho"]
    }
}
