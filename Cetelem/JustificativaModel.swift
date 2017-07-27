//
//  JustificativaModel.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 27/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation

class JustificativaModel {
    
    var id: Int
    var texto: String
    
    var dictionary: [String: Any] {
        return [
            "id": id,
            "texto": texto
        ]
    }
    
    init(_ id: Int, _ texto: String) {
        self.id = id
        self.texto = texto
    }
}
