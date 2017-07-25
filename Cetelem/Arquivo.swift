//
//  Arquivo.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 25/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation
import RealmSwift

class Arquivo: Object {
    
    dynamic var id = 0
    dynamic var caminho = ""
    
    dynamic var digitalizacao: Digitalizacao?
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    static func from(_ model: ArquivoModel) -> Arquivo {
        let arquivo = Arquivo()
        arquivo.id = model.id
        arquivo.caminho = model.caminho
        return arquivo
    }
}
