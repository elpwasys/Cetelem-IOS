//
//  ArquivoModel.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 25/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation
import RealmSwift

class ArquivoModel {
    
    let id: Int
    let caminho: String
    
    init(id: Int, caminho: String) {
        self.id = id
        self.caminho = caminho
    }
    
    static func from(_ arquivo: Arquivo) -> ArquivoModel {
        return ArquivoModel(id: arquivo.id, caminho: arquivo.caminho)
    }
    
    static func from(_ arquivos: List<Arquivo>) -> [ArquivoModel] {
        var models = [ArquivoModel]()
        for arquivo in arquivos {
            models.append(from(arquivo))
        }
        return models
    }
}
