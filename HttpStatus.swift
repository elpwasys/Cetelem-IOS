//
//  HttpStatus.swift
//  AppKit
//
//  Created by Everton Luiz Pascke on 18/11/16.
//  Copyright © 2016 Everton Luiz Pascke. All rights reserved.
//

import Foundation

enum HttpStatus: Int {
    
    // 0xx Unknown
    case unknown = 0
    case notApply = 1
    
    // 1xx Informational
    case `continue` = 100
    case switchingProtocols = 101
    case processing = 102
    case checkpoint = 103
    
    // 2xx Success
    case ok = 200
    case created = 201
    case accepted = 202
    case nonAuthoritativeInformation = 203
    case noContent = 204
    case resetContent = 205
    case partialContent = 206
    case multiStatus = 207
    case alreadyReported = 208
    case imUsed = 226
    
    // 3xx Redirection
    case multipleChoices = 300
    case movedPermanently = 301
    case found = 302
    case seeOther = 303
    case notModified = 304
    case temporaryRedirect = 307
    case permanentRedirect = 308
    
    // 4xx Client Error
    case badRequest = 400
    case unauthorized = 401
    case paymentRequired = 402
    case forbidden = 403
    case notFound = 404
    case methodNotAllowed = 405
    case notAcceptable = 406
    case proxyAuthenticationRequired = 407
    case requestTimeout = 408
    case conflict = 409
    case gone = 410
    case lengthRequired = 411
    case preconditionFailed = 412
    case payloadTooLarge = 413
    case uriTooLong = 414
    case unsupportedMediaType = 415
    case requestedRangeNotSatisfiable = 416
    case expectationFailed = 417
    case imTeapot = 418
    case unprocessableEntity = 422
    case locked = 423
    case failedDependency = 424
    case upgradeRequired = 426
    case preconditionRequired = 428
    case tooManyRequests = 429
    case requestHeaderFieldsTooLarge = 431
    case unavailableForLegalReasons = 451
    
    // 5xx Server Error
    case internalServerError = 500
    case notImplemented = 501
    case badGateway = 502
    case serviceUnavailable = 503
    case gatewayTimeout = 504
    case httpVersionNotSupported = 505
    case variantAlsoNegotiates = 506
    case insufficientStorage = 507
    case loopDetected = 508
    case bandwidthLimitExceeded = 509
    case notExtended = 510
    case networkAuthenticationRequired = 511
    
    var reason: String {
        switch self {
        // 0xx Unknown
        case .unknown: return "Unknow"
        case .notApply: return "Not Apply"
        // 1xx Informational
        case .continue: return "Continue"
        case .switchingProtocols: return "Switching Protocols"
        case .processing: return "Processing"
        case .checkpoint: return "Checkpoint"
        // 2xx Success
        case .ok: return "OK"
        case .created: return "Created"
        case .accepted: return "Accepted"
        case .nonAuthoritativeInformation: return "Non-Authoritative Information"
        case .noContent: return "No Content"
        case .resetContent: return "Reset Content"
        case .partialContent: return "Partial Content"
        case .multiStatus: return "Multi-Status"
        case .alreadyReported: return "Already Reported"
        case .imUsed: return "IM Used"
        // 3xx Redirection
        case .multipleChoices: return "Multiple Choices"
        case .movedPermanently: return "Moved Permanently"
        case .found: return "Found"
        case .seeOther: return "See Other"
        case .notModified: return "Not Modified"
        case .temporaryRedirect: return "Temporary Redirect"
        case .permanentRedirect: return "Permanent Redirect"
        // 4xx Client Error
        case .badRequest: return "Bad Request"
        case .unauthorized: return "Unauthorized"
        case .paymentRequired: return "Payment Required"
        case .forbidden: return "Forbidden"
        case .notFound: return "Not Found"
        case .methodNotAllowed: return "Method Not Allowed"
        case .notAcceptable: return "Not Acceptable"
        case .proxyAuthenticationRequired: return "Proxy Authentication Required"
        case .requestTimeout: return "Request Timeout"
        case .conflict: return "Conflict"
        case .gone: return "Gone"
        case .lengthRequired: return "Length Required"
        case .preconditionFailed: return "Precondition Failed"
        case .payloadTooLarge: return "Payload Too Large"
        case .uriTooLong: return "URI Too Long"
        case .unsupportedMediaType: return "Unsupported Media Type"
        case .requestedRangeNotSatisfiable: return "Requested range not satisfiable"
        case .expectationFailed: return "Expectation Failed"
        case .imTeapot: return "I'm a teapot"
        case .unprocessableEntity: return "Unprocessable Entity"
        case .locked: return "Locked"
        case .failedDependency: return "Failed Dependency"
        case .upgradeRequired: return "Upgrade Required"
        case .preconditionRequired: return "Precondition Required"
        case .tooManyRequests: return "Too Many Requests"
        case .requestHeaderFieldsTooLarge: return "Request Header Fields Too Large"
        case .unavailableForLegalReasons: return "Unavailable For Legal Reasons"
        // 5xx Server Error
        case .internalServerError: return "Internal Server Error"
        case .notImplemented: return "Not Implemented"
        case .badGateway: return "Bad Gateway"
        case .serviceUnavailable: return "Service Unavailable"
        case .gatewayTimeout: return "Gateway Timeout"
        case .httpVersionNotSupported: return "HTTP Version not supported"
        case .variantAlsoNegotiates: return "Variant Also Negotiates"
        case .insufficientStorage: return "Insufficient Storage"
        case .loopDetected: return "Loop Detected"
        case .bandwidthLimitExceeded: return "Bandwidth Limit Exceeded"
        case .notExtended: return "Not Extended"
        case .networkAuthenticationRequired: return "Network Authentication Required"
        }
    }
    
    var series: Series {
        return Series.valueOf(status: self)
    }
    
    func is1xxInformational() -> Bool {
        return Series.informational == series
    }
    
    func is2xxSuccessful() -> Bool {
        return Series.successful == series
    }
    
    func is3xxRedirection() -> Bool {
        return Series.redirection == series
    }
    
    func is4xxClientError() -> Bool {
        return Series.clientError == series
    }
    
    func is5xxServerError() -> Bool {
        return Series.serverError == series
    }
    
    enum Series: Int {
        case unknown = 0
        case informational = 1
        case successful = 2
        case redirection = 3
        case clientError = 4
        case serverError = 5
        static func valueOf(status: HttpStatus) -> Series {
            return valueOf(status: status.rawValue)
        }
        static func valueOf(status: Int) -> Series {
            let code = status / 100
            guard let series = Series(rawValue: code) else {
                return Series.unknown
            }
            return series
        }
    }
}
