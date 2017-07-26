//
//  ProcessoLogModel.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 26/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation
import ObjectMapper

class ProcessoLogModel: Model {
    
    var observacao: String?
    var observacaoCurta: String?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        observacao <- map["observacao"]
        observacaoCurta <- map["observacaoCurta"]
    }
}
