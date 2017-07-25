//
//  DateUtils.swift
//  AppKit
//
//  Created by Everton Luiz Pascke on 17/11/16.
//  Copyright © 2016 Everton Luiz Pascke. All rights reserved.
//

import Foundation

public enum DateType {
    
    case date
    case dateBr
    case iso8601
    case dateTimeBr
    case dateHourMinuteBr
    
    public var pattern: String {
        switch self {
        case .date:
            return "yyyy-MM-dd"
        case .dateBr:
            return "dd/MM/yyyy"
        case .iso8601:
            return "yyyy-MM-dd'T'HH:mm:ssz"
        case .dateTimeBr:
            return "dd/MM/yyyy HH:mm:ss"
        case .dateHourMinuteBr:
            return "dd/MM/yyyy HH:mm"
        }
    }
}

public class DateUtils {
    
    public static let patterns = [
        DateType.date.pattern,
        DateType.dateBr.pattern,
        DateType.iso8601.pattern,
        DateType.dateTimeBr.pattern,
        DateType.dateHourMinuteBr.pattern
    ]
    
    public static func parse(_ text: String) -> Date? {
        return parse(text, patterns: patterns)
    }
    
    public static func parse(_ text: String, type: DateType) -> Date? {
        return parse(text, pattern: type.pattern)
    }
    
    public static func parse(_ text: String, pattern: String...) -> Date? {
        return parse(text, patterns: pattern)
    }
    
    public static func format(_ date: Date, type: DateType) -> String {
        return format(date, pattern: type.pattern)
    }
    
    public static func format(_ date: Date, pattern: String? = DateType.iso8601.pattern) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = pattern
        return formatter.string(from: date)
    }
    
    private static func parse(_ text: String, patterns: [String]) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = App.locale
        for pattern in patterns {
            formatter.dateFormat = pattern
            if let date = formatter.date(from: text) {
                return date
            }
        }
        return nil
    }
}
