//
//  RealmService.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 25/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation
import RealmSwift

class RealmService: Service {
    
    static func nextId<T: Object>(_ type: T.Type) throws -> Int {
        let realm = try Realm()
        return (realm.objects(type).max(ofProperty: "id") as Int? ?? 0) + 1
    }
}
