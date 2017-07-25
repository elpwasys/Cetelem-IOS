//
//  NumberUtils.swift
//  AppKit
//
//  Created by Everton Luiz Pascke on 17/11/16.
//  Copyright © 2016 Everton Luiz Pascke. All rights reserved.
//

import Foundation

public class NumberUtils {
    
    public static func format(_ value: Float) -> String? {
        let number = NSNumber.init(value: value)
        return format(number)
    }
    
    public static func format(_ value: Double) -> String? {
        let number = NSNumber.init(value: value)
        return format(number)
    }
    
    public static func format(_ value: NSNumber) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = App.locale
        return formatter.string(from: value)
    }
}
