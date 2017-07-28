//
//  Icon.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 21/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit

struct Icon {
    static func icon(_ named: String) -> UIImage? {
        return UIImage(named: named)/*?.withRenderingMode(.alwaysTemplate)*/
    }
    static let add = icon("ic_add")
    static let info = icon("ic_info")
    static let menu = icon("ic_menu")
    static let lock = icon("ic_lock")
    static let camera = icon("ic_camera")
    static let search = icon("ic_search")
    static let person = icon("ic_person")
    static let refresh = icon("ic_refresh")
    static let arrowBack = icon("ic_arrow_back")
    static let arrowDropDown = icon("ic_arrow_drop_down")
    static let powerSettingsNew = icon("ic_power_settings_new")
    static let keyboardArrowLeft = icon("ic_keyboard_arrow_left")
    static let keyboardArrowRight = icon("ic_keyboard_arrow_right")
    static let modeEditWhite = icon("ic_mode_edit_white")
    static let sendWhite = icon("ic_send_white")
    static let saveWhite = icon("ic_save_white")
    static let collectionsWhite = icon("ic_collections_white")
    static let undoWhite = icon("ic_undo_white")
    static let dateRange = icon("ic_date_range")
}
