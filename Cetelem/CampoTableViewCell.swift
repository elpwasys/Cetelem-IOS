//
//  CampoTableViewCellProtocol.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 11/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit

class CampoTableViewCell: UITableViewCell {

    var value: String? {
        return nil
    }
    
    var isValid: Bool {
        return true
    }
    
    var isEnabled = true
    
    var detailColor: UIColor {
        return Color.grey400
    }
    
    var detailErrorColor: UIColor {
        return Color.red500
    }
    
    func prepare(_ model: CampoModel) {
        
    }
}
