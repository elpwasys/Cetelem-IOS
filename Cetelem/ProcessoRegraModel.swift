//
//  ProcessoRegraModel.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 25/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation
import ObjectMapper

class ProcessoRegraModel: Model {
    
    var podeEnviar = false
    var podeEditar = false
    var podeExcluir = false
    var podeDigitalizar = false
    var podeResponderPendencia = false
    
    var pendencias: [Pendencia: String]?

    enum Pendencia: String {
        case digitalizacao = "DIGITALIZACAO"
        case analiseDocumentos = "ANALISE_DOCUMENTOS"
        case pendenciaDocumento = "PENDENCIA_DOCUMENTO"
        case naoPendenciaDocumento = "NAO_PENDENCIA_DOCUMENTO"
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        podeEnviar <- map["podeEnviar"]
        podeEditar <- map["podeEditar"]
        podeExcluir <- map["podeExcluir"]
        podeDigitalizar <- map["podeDigitalizar"]
        podeResponderPendencia <- map["podeResponderPendencia"]
        pendencias <- map["pendencias"]
    }
    
    func hasAnyPendencia() -> Bool {
        if let pendencias = self.pendencias {
            return !pendencias.isEmpty
        }
        return false
    }
}
