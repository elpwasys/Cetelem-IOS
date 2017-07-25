//
//  Button.swift
//  GetDocAg
//
//  Created by Everton Luiz Pascke on 07/02/17.
//  Copyright © 2017 Everton Luiz Pascke. All rights reserved.
//

import UIKit

@IBDesignable
class Button: UIButton {
    
    @IBInspectable open var normalTextColor: UIColor = UIColor.lightGray {
        didSet {
            setTitleColor(normalTextColor, for: UIControlState())
        }
    }
    
    @IBInspectable open var disabledTextColor: UIColor = UIColor.lightGray {
        didSet {
            setTitleColor(disabledTextColor, for: UIControlState.disabled)
        }
    }
    
    @IBInspectable open var selectedTextColor: UIColor = UIColor.lightGray {
        didSet {
            setTitleColor(selectedTextColor, for: UIControlState.selected)
        }
    }
    
    @IBInspectable open var highlightedTextColor: UIColor = UIColor.lightGray {
        didSet {
            setTitleColor(highlightedTextColor, for: UIControlState.highlighted)
        }
    }
    
    @IBInspectable open var normalBackgroundColor: UIColor = UIColor.white {
        didSet {
            updateColor()
        }
    }
    
    @IBInspectable open var disabledBackgroundColor: UIColor = UIColor.white {
        didSet {
            updateColor()
        }
    }
    
    @IBInspectable open var selectedBackgroundColor: UIColor = UIColor(red: 37.0/255.0, green: 147.0/255.0, blue: 1.0/255.0, alpha: 1.0) {
        didSet {
            updateColor()
        }
    }
    
    @IBInspectable open var normalBorderColor: UIColor = UIColor.lightGray {
        didSet {
            updateColor()
        }
    }
    
    @IBInspectable open var disabledBorderColor: UIColor = UIColor.lightGray {
        didSet {
            updateColor()
        }
    }
    
    @IBInspectable open var selectedBorderColor: UIColor = UIColor(red: 37.0/255.0, green: 147.0/255.0, blue: 1.0/255.0, alpha: 1.0) {
        didSet {
            updateColor()
        }
    }
    
    @IBInspectable open var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable open var borderWidth: CGFloat = 1.0 {
        didSet {
            layer.borderWidth = borderWidth / UIScreen.main.scale
        }
    }

    override var isEnabled: Bool {
        didSet {
            updateColor()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            updateColor()
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func updateColor() {
        backgroundColor = isEnabled ? (isSelected ? selectedBackgroundColor : normalBackgroundColor) : disabledBackgroundColor
        layer.borderColor = isEnabled ? (isSelected ? selectedBorderColor.cgColor : normalBorderColor.cgColor) : disabledBorderColor.cgColor
    }
}
