//
//  PickerField.swift
//  Novar
//
//  Created by Everton Luiz Pascke on 01/12/16.
//  Copyright © 2016 Everton Luiz Pascke. All rights reserved.
//

import Foundation
import ObjectMapper

protocol Selectable {
    var value: String { get }
    var label: String { get }
}

protocol PickerFieldDelegate: UITextFieldDelegate {
    func pickerField(_ pickerField: PickerField, selected: Selectable?)
}

class Option: Mappable, Selectable {
    
    var value = ""
    var label = ""
    
    init(_ label: String) {
        self.value = label
        self.label = label
    }
    
    required init?(map: Map) {
        
    }
    
    init(value: String, label: String) {
        self.value = value
        self.label = label
    }
    
    func mapping(map: Map) {
        value <- map["value"]
        label <- map["label"]
    }
}

class PickerField: MaterialTextField {
    
    fileprivate let pickerView = UIPickerView()
    fileprivate var selectables = [Selectable]()
    
    var value: Selectable? {
        didSet {
            guard let selectable = self.value else {
                text = nil
                return
            }
            text = selectable.label
            let contains = selectables.contains { return $0.value == selectable.value }
            if !contains {
                selectables.append(selectable)
                reset()
            }
            let index = selectables.index { return $0.value == selectable.value }!
            pickerView.selectRow(index, inComponent: 0, animated: false)
        }
    }
    
    var isRequired = false {
        didSet {
            reset()
        }
    }
    
    var numberOfRows: Int {
        return selectables.count
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        inputView = pickerView
        pickerView.delegate = self
    }
    
    func hide() {
        _ = resignFirstResponder()
    }
    
    func show() {
        _ = becomeFirstResponder()
    }
    
    func reset() {
        let option = Option(TextUtils.localized(forKey: "Label.Selecione"))
        let contains = selectables.contains { return $0.value == option.value }
        if !isRequired {
            if !contains {
                selectables.insert(option, at: 0)
            }
        } else if contains {
            selectables.removeFirst()
        }
        pickerView.reloadAllComponents()
    }
    
    func clear() {
        value = nil
        selectables.removeAll()
    }
    
    func entries(array: [Selectable]?) {
        if array == nil {
            clear()
        } else {
            selectables = array!
        }
        reset()
    }
    
    func entries(array: [String]?) {
        var options: [Option]?
        if array != nil {
            options = [Option]()
            for element in array! {
                options!.append(Option(element))
            }
        }
        entries(array: options)
    }
    
    func entries(dictionary: [String: String]?) {
        var options: [Option]?
        if dictionary != nil {
            for (value, label) in dictionary! {
                options!.append(Option(value: value, label: label))
            }
        }
        entries(array: options)
    }
}

// MARK: UIPickerViewDelegate
extension PickerField: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        value = nil
        if isRequired || row > 0 {
            value = selectables[row]
        }
        if let delegate = self.delegate as? PickerFieldDelegate {
            delegate.pickerField(self, selected: value)
        }
    }
}

// MARK: UIPickerViewDataSource
extension PickerField: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return selectables.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return selectables[row].label
    }
    
}
