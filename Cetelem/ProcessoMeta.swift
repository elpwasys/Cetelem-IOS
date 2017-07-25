//
//  ProcessoMeta.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 09/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation
import ObjectMapper

class ProcessoMeta: Mappable {
    
    var tiposProcessos: [TipoProcessoModel]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        tiposProcessos <- map["tiposProcessos"]
    }
}
