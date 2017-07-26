//
//  DocumentoMeta.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 26/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation
import ObjectMapper

class DocumentoMeta: Mappable {
    
    var log: ProcessoLogModel?
    var regra: ProcessoRegraModel?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        log <- map["log"]
        regra <- map["regra"]
    }
}
