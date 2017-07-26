//
//  ArrayDataSet.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 26/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation
import ObjectMapper

class ArrayDataSet<Data: Mappable, Meta: Mappable>: Mappable {
    
    var meta: Meta?
    var data: [Data]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        meta <- map["meta"]
        data <- map["data"]
    }
}
