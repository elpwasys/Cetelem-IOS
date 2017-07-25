//
//  Trouble.swift
//
//  Created by Everton Luiz Pascke on 31/01/17.
//  Copyright © 2017 Everton Luiz Pascke. All rights reserved.
//

import Foundation

enum Trouble: Error {
    case any(String)
    case internetNotAvailable(String)
    case server(HttpStatus, [String]?)
    var description: String {
        switch self {
        case .any(let reason), .internetNotAvailable(let reason):
            return reason
        case .server(let status, let messages):
            guard let messages = messages else {
                return status.reason
            }
            var message = String()
            for (index, value) in messages.enumerated() {
                if index > 0 {
                    message.append(", ")
                }
                message.append(value)
            }
            return message
        }
    }
}

enum MapperError: Error {
    case failed
}
