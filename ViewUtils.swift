//
//  ViewUtils.swift
//  Self
//
//  Created by Everton Luiz Pascke on 31/01/17.
//  Copyright © 2017 Everton Luiz Pascke. All rights reserved.
//

import UIKit

class ViewUtils {
    
    static func text(_ value: Any?, for label: UILabel) {
        label.text = TextUtils.text(value)
    }
    
    static func text(_ value: Any?, for field: UITextView) {
        field.text = TextUtils.text(value)
    }
    
    static func text(_ value: Any?, for field: UITextField) {
        field.text = TextUtils.text(value)
    }
}
