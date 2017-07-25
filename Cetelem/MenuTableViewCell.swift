//
//  MenuTableViewCell.swift
//  ClubeMesa
//
//  Created by Everton Luiz Pascke on 10/06/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func populate(_ menu: Menu) {
        self.icon.image = menu.icon
        ViewUtils.text(menu.label, for: self.label)
    }
}
