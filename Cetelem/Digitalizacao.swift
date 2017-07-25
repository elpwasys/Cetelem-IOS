//
//  Digitalizacao.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 25/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation
import RealmSwift

class Digitalizacao: Object {
    
    dynamic var id = 0
    dynamic var tentativas = 0
    
    dynamic var tipo = ""
    dynamic var status = ""
    dynamic var referencia = ""
    dynamic var mensagem: String? = nil
    
    dynamic var dataHora = Date()
    dynamic var dataHoraEnvio: Date? = nil
    dynamic var dataHoraRetorno: Date? = nil
    
    let arquivos = List<Arquivo>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
