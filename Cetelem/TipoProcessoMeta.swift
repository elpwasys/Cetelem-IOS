//
//  TipoProcessoMeta.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 10/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation
import ObjectMapper

class TipoProcessoMeta: Mappable {
    
    var gruposCampos: [CampoGrupoModel]?
    var tiposDocumentos: [TipoDocumentoModel]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        gruposCampos <- map["gruposCampos"]
        tiposDocumentos <- map["tiposDocumentos"]
    }
}
