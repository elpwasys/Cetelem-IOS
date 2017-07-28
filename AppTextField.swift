//
//  AppTextField.swift
//
//  Created by Everton Luiz Pascke on 11/01/17.
//  Copyright © 2017 Everton Luiz Pascke. All rights reserved.
//

import UIKit

class AppTextField: UITextField {
    
    var borderColor: UIColor!
    var borderWidth: CGFloat = 2.0
    
    var leftImage: UIImage? {
        didSet {
            drawLeftImage()
        }
    }
    
    var rightImage: UIImage? {
        didSet {
            drawRightImage()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        borderStyle = .none
        super.draw(rect)
        if let context = UIGraphicsGetCurrentContext() {
            context.setLineWidth(borderWidth)
            context.setStrokeColor(borderColor.cgColor)
            context.move(to: CGPoint(x: 0, y: frame.height - borderWidth))
            context.addLine(to: CGPoint(x: frame.width, y: frame.height - borderWidth))
            context.strokePath()
        }
    }
    
    func drawLeftImage() {
        if let image = self.leftImage {
            let imageView = UIImageView(image: image.withRenderingMode(.alwaysTemplate))
            imageView.tintColor = textColor
            leftView = imageView
            leftView?.frame = CGRect(x: 0, y: 0, width: CGFloat(imageView.frame.width + Dimens.half), height: imageView.frame.height)
            leftView?.contentMode = .scaleAspectFit
            leftView?.clipsToBounds = true
            leftViewMode = .always
        }
    }
    
    func drawRightImage() {
        if let image = self.rightImage {
            let imageView = UIImageView(image: image.withRenderingMode(.alwaysTemplate))
            imageView.tintColor = textColor
            rightView = imageView
            rightView?.frame = CGRect(x: 0, y: 0, width: CGFloat(imageView.frame.width + Dimens.half), height: imageView.frame.height)
            rightView?.contentMode = .scaleAspectFit
            rightView?.clipsToBounds = true
            rightViewMode = .always
        }
    }
}
