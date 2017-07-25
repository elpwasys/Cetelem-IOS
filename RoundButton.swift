//
//  RoundButton.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 24/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit

@IBDesignable
class RoundButton: Button {

    override public init(frame: CGRect) {
        super.init(frame: frame)
        updateLayerSettings()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        updateLayerSettings()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayerSettings()
    }
    
    private func updateLayerSettings() {
        layer.cornerRadius = frame.size.height * 0.5
        layer.rasterizationScale = UIScreen.main.scale
        layer.shouldRasterize = true
        ShadowUtils.apply(self, offset: CGSize(width: 0, height: 3.0))
    }
}
