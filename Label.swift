//
//  Label.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 11/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit

@IBDesignable
class Label: UILabel {

    @IBInspectable var lineColor: UIColor!
    @IBInspectable var lineWidth: CGFloat = 2.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if let context = UIGraphicsGetCurrentContext() {
            context.setLineWidth(lineWidth)
            context.setStrokeColor(lineColor.cgColor)
            context.move(to: CGPoint(x: 0, y: frame.height - lineWidth))
            context.addLine(to: CGPoint(x: frame.width, y: frame.height - lineWidth))
            context.strokePath()
        }
    }
}
