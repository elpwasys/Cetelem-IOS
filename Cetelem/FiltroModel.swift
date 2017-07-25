//
//  FiltroModel.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 09/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation

class FiltroModel: Model {
    
    var numero: String?
    var dataInicio: Date?
    var dataTermino: Date?
    var tipoProcessoId: Int?
    var status: ProcessoModel.Status?
    
    var parameters: [String: String] {
        var parameters = [String: String]()
        if TextUtils.isNotBlank(self.numero) {
            parameters["numero"] = self.numero!
        }
        if let dataInicio = self.dataInicio {
            parameters["dataInicio"] = TextUtils.text(dataInicio, type: .dateBr)
        }
        if let dataTermino = self.dataTermino {
            parameters["dataTermino"] = TextUtils.text(dataTermino, type: .dateBr)
        }
        if let tipoProcessoId = self.tipoProcessoId {
            parameters["tipoProcessoId"] = "\(tipoProcessoId)"
        }
        if let status = self.status {
            parameters["status"] = status.rawValue
        }
        return parameters
    }
}
