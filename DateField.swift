//
//  DateField.swift
//  Novar
//
//  Created by Everton Luiz Pascke on 21/10/16.
//  Copyright © 2016 Everton Luiz Pascke. All rights reserved.
//

import UIKit

@IBDesignable
class DateField: MaterialTextField {

    var date: Date? {
        if let text = text, !text.isEmpty {
            return DateUtils.parse(text)
        }
        return nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    private func configure() {
        keyboardType = .numberPad
    }
}
