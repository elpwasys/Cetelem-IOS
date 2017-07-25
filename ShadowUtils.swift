//
//  ShadowUtils.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 10/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//
import UIKit

class ShadowUtils {
    
    static func apply(_ view: UIView, color: UIColor = Color.black, opacity: Float = 0.2, offset: CGSize) {
        view.layer.shadowColor = color.cgColor
        view.layer.shadowOpacity = opacity
        view.layer.shadowOffset = offset
    }
    
    static func applyTop(_ view: UIView) {
        apply(view, offset: CGSize(width: 0, height: -2.0))
    }
    
static func applyBottom(_ view: UIView) {
        apply(view, offset: CGSize(width: 0, height: 2.0))
    }
}
