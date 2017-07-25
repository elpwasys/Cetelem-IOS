//
//  MaterialTextField.swift
//
//  Created by Everton Luiz Pascke on 11/01/17.
//  Copyright © 2017 Everton Luiz Pascke. All rights reserved.
//

import UIKit

class MaterialTextField: UITextField {
    
    var error: String? {
        didSet {
            updateErrorLabel()
        }
    }
    
    var detail: String? {
        didSet {
            
        }
    }
    
    fileprivate var width: CGFloat {
        return self.frame.width
    }
    
    fileprivate var height: CGFloat {
        return self.frame.height
    }
    
    fileprivate lazy var padding: CGFloat = {
        return Dimens.half
    }()
    
    fileprivate lazy var labelHeight: CGFloat = {
        return 12
    }()
    
    fileprivate lazy var topLabel: UILabel = {
        let size = CGSize(width: self.width, height: self.labelHeight)
        let origin = CGPoint(x: 0, y: ((self.labelHeight + self.padding) * -1))
        let label = UILabel(frame: CGRect(origin: origin, size: size))
        label.font = self.font?.withSize(self.labelHeight)
        self.addSubview(label)
        return label
    }()
    
    fileprivate lazy var bottomLabel: UILabel = {
        let size = CGSize(width: self.width, height: self.labelHeight)
        let origin = CGPoint(x: 0, y: (self.height + self.padding))
        let label = UILabel(frame: CGRect(origin: origin, size: size))
        label.font = self.font?.withSize(self.labelHeight)
        self.addSubview(label)
        return label
    }()
    
    fileprivate lazy var divider: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: (self.height - self.dividerWidth), width: self.width, height: self.dividerWidth))
        view.backgroundColor = self.dividerNormalColor
        self.addSubview(view)
        return view
    }()
    
    var dividerWidth: CGFloat = 1.0
    
    var labelNormalColor: UIColor? {
        didSet {
            self.topLabel.tintColor = labelNormalColor
        }
    }
    
    var labelActiveColor: UIColor? {
        didSet {
            self.topLabel.tintColor = labelActiveColor
        }
    }
    
    var dividerNormalColor: UIColor? {
        didSet {
            self.leftView?.tintColor = dividerNormalColor
            self.rightView?.tintColor = dividerNormalColor
            self.divider.backgroundColor = dividerNormalColor
        }
    }
    
    var dividerActiveColor: UIColor? {
        didSet {
            self.leftView?.tintColor = dividerActiveColor
            self.rightView?.tintColor = dividerActiveColor
            self.divider.backgroundColor = dividerActiveColor
        }
    }
    
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
        prepare()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepare()
    }
    
    func drawLeftImage() {
        if let image = self.leftImage {
            let imageView = UIImageView(image: image.withRenderingMode(.alwaysTemplate))
            imageView.tintColor = dividerNormalColor
            leftView = imageView
            leftView?.frame = CGRect(x: 0, y: 0, width: CGFloat(imageView.frame.width + padding), height: imageView.frame.height)
            leftView?.contentMode = .scaleAspectFit
            leftView?.clipsToBounds = true
            leftViewMode = .always
        }
    }
    
    func drawRightImage() {
        if let image = self.rightImage {
            let imageView = UIImageView(image: image.withRenderingMode(.alwaysTemplate))
            imageView.tintColor = dividerNormalColor
            rightView = imageView
            rightView?.frame = CGRect(x: 0, y: 0, width: CGFloat(imageView.frame.width + padding), height: imageView.frame.height)
            rightView?.contentMode = .scaleAspectFit
            rightView?.clipsToBounds = true
            rightViewMode = .always
        }
    }
}

extension MaterialTextField {
    
    fileprivate func prepare() {
        borderStyle = .none
        prepareTargetHandlers()
    }
    
    fileprivate func prepareTargetHandlers() {
        addTarget(self, action: #selector(didEndEditing), for: .editingDidEnd)
        addTarget(self, action: #selector(didBeginEditing), for: .editingDidBegin)
    }
    
    fileprivate func updateErrorLabel() {
        bottomLabel.text = error
        var color = dividerNormalColor
        if TextUtils.isNotBlank(bottomLabel.text) {
            color = Color.red500
        }
        divider.backgroundColor = color
        bottomLabel.textColor = color
        leftView?.tintColor = color
        rightView?.tintColor = color
    }
    
    @objc fileprivate func didEndEditing() {
        var color = dividerNormalColor
        if TextUtils.isNotBlank(self.error) {
            color = Color.red500
        }
        divider.backgroundColor = color
        leftView?.tintColor = color
        rightView?.tintColor = color
        topLabel.textColor = labelNormalColor
        if TextUtils.isBlank(self.text) {
            topLabel.text = nil
        }
    }
    
    @objc fileprivate func didBeginEditing() {
        divider.backgroundColor = dividerActiveColor
        leftView?.tintColor = dividerActiveColor
        rightView?.tintColor = dividerActiveColor
        topLabel.text = placeholder
        topLabel.textColor = labelActiveColor
    }
}
