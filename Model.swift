//
//  Model.swift
//
//  Created by Everton Luiz Pascke on 07/11/16.
//  Copyright © 2016 Everton Luiz Pascke. All rights reserved.
//

import Foundation
import ObjectMapper

class Model: Mappable {
    
    var id: Int?
    
    init() {
        
    }
    
    init(_ id: Int) {
        self.id = id
    }
    
    required init?(map: Map) {
        
    }

    func mapping(map: Map) {
        id <- (map["id"], IdentifierTransformType())
    }
}
