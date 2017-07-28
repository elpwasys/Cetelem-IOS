//
//  AppDateField.swift
//  Novar
//
//  Created by Everton Luiz Pascke on 21/10/16.
//  Copyright © 2016 Everton Luiz Pascke. All rights reserved.
//

import UIKit

class AppDateField: AppTextField {

    private let datePicker: UIDatePicker = UIDatePicker()
    
    var date: Date? {
        if let text = text, !text.isEmpty {
            return DateUtils.parse(text)
        }
        return nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(handle(sender:)), for: UIControlEvents.valueChanged)
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(AppDateField.onDonePressed))
        
        toolBar.setItems([ space, doneButton ], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        
        inputView = datePicker
        /*
         rightView = UIImageView(image: UIImage(named: "arrowDate"))
         rightView?.contentMode = .scaleAspectFit
         rightView?.clipsToBounds = true
         rightViewMode = .always
         */
        
        inputAccessoryView = toolBar

    }
    
    func onDonePressed() {
        endEditing(true)
        text = DateUtils.format(datePicker.date, pattern: DateType.dateBr.pattern)
    }
    
    func handle(sender: UIDatePicker) {
        text = DateUtils.format(sender.date, pattern: DateType.dateBr.pattern)
    }
}
