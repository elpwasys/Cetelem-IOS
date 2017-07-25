//
//  TableHeaderView.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 11/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit

class TableHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var label: Label!
    
    static var height: CGFloat {
        return 56
    }
    
    static var nibName: String {
        return "\(TableHeaderView.self)"
    }
    
    static var reusableCellIdentifier: String {
        return "\(TableHeaderView.self)"
    }
    
    func prepare(_ nome: String) {
        label.textColor = Color.accent
        label.lineColor = Color.accent
        ViewUtils.text(TextUtils.capitalize(nome), for: label)
    }
}
