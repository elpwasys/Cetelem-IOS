//
//  PagingModel.swift
//  Novar
//
//  Created by Everton Luiz Pascke on 08/11/16.
//  Copyright © 2016 Everton Luiz Pascke. All rights reserved.
//

import Foundation
import ObjectMapper

class PagingModel<T: Mappable>: Mappable {
    
    var page = 0
    var qtde = 0
    var count = 0
    var pageSize = 0
    
    var records = [T]()
    
    var nexPage: Int {
        if hasNext() {
            return page + 1
        }
        return page
    }
    
    var previousPage: Int {
        if hasPrevious() {
            return page - 1
        }
        return page
    }
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        page <- map["page"]
        qtde <- map["qtde"]
        count <- map["count"]
        pageSize <- map["pageSize"]
        records <- map["records"]
    }
    
    func hasNext() -> Bool {
        return page < (qtde - 1)
    }
    
    func hasPrevious() -> Bool {
        return page > 0
    }
}
