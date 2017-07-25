//
//  PesquisaModel.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 09/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation

class PesquisaModel: Model {
    
    var page = 0
    var filtro: FiltroModel?
    var parameters: [String: Any] {
        var parameters = [String: Any]()
        parameters["page"] = self.page
        if let filtro = self.filtro {
            parameters["filtro"] = filtro.parameters
        }
        return parameters
    }
}
