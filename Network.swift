//
//  Network.swift
//  ClubMesa
//
//  Created by Everton Luiz Pascke on 08/06/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation

import Alamofire
import ObjectMapper

class Network {
    
    static func validateAvailability() throws {
        guard Reachability.isNetworkAvailable() else {
            let message = TextUtils.localized(forKey: "Message.InternetIndisponivel")
            throw Trouble.internetNotAvailable(message)
        }
    }
    
    static func request(
        _ url: URLConvertible,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil) throws -> DataRequest {
        try validateAvailability()
        return Alamofire.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers)
    }
    
    static func upload(
        multipartFormData: @escaping (MultipartFormData) -> Void,
        usingThreshold encodingMemoryThreshold: UInt64 = SessionManager.multipartFormDataEncodingMemoryThreshold,
        to url: URLConvertible,
        method: HTTPMethod = .post,
        headers: HTTPHeaders? = nil,
        encodingCompletion: ((SessionManager.MultipartFormDataEncodingResult) -> Void)?) throws {
        try validateAvailability()
        return SessionManager.default.upload(
            multipartFormData: multipartFormData,
            usingThreshold: encodingMemoryThreshold,
            to: url,
            method: method,
            headers: headers,
            encodingCompletion: encodingCompletion
        )
    }
}

// MARK: ObjectMapper
class DateTransformType: TransformType {
    typealias JSON = String
    typealias Object = Date
    var dateType: DateType
    init(type: DateType? = .dateBr) {
        self.dateType = type!
    }
    func transformToJSON(_ value: Date?) -> String? {
        guard let value = value else {
            return nil
        }
        return DateUtils.format(value, pattern: dateType.pattern)
    }
    func transformFromJSON(_ value: Any?) -> Date? {
        guard let value = value as? String else {
            return nil
        }
        return DateUtils.parse(value)
    }
}

class IdentifierTransformType: TransformType {
    typealias JSON = Int
    typealias Object = Int
    init() {}
    func transformToJSON(_ value: Int?) -> Int? {
        return value
    }
    func transformFromJSON(_ value: Any?) -> Int? {
        if let value = value as? Int {
            return value
        }
        if let text = value as? String, let id = Int(text) {
            return id
        }
        return nil
    }
}

// MARK: Alamofire
extension DataRequest {
    
    open static func validate(default: DefaultDataResponse) throws {
        let data = `default`.data
        let error = `default`.error
        let request = `default`.request
        let response = `default`.response
        try validate(request: request, response: response, data: data, error: error)
    }
    
    open static func validate(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) throws {
        if let error = error {
            throw error
        }
        guard let data = data else {
            throw Trouble.any("Data could not be serialized. Input data is nil.")
        }
        guard let response = response else {
            throw Trouble.any("Data could not be serialized. Input response is nil.")
        }
        guard let httpStatus = HttpStatus(rawValue: response.statusCode) else {
            throw Trouble.any("Data could not be serialized. HttpStatus not defined.")
        }
        guard httpStatus.is2xxSuccessful() else {
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String:Any]
                let messages = json?["messages"] as? [String]
                throw Trouble.server(httpStatus, messages)
            } catch {
                throw error
            }
        }
    }
    
    open static func serializer<T: BaseMappable>(_ path: String?) -> DataResponseSerializer<[T]> {
        return DataResponseSerializer { request, response, data, error in
            do {
                try validate(request: request, response: response, data: data, error: error)
                let serializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
                let result = serializer.serializeResponse(request, response, data, error)
                let json: Any?
                if let path = path, path.isEmpty == false {
                    json = (result.value as AnyObject?)?.value(forKeyPath: path)
                } else {
                    json = result.value
                }
                if let mapper = Mapper<T>().mapArray(JSONObject: json) {
                    return .success(mapper)
                }
                throw MapperError.failed
            } catch {
                return .failure(error)
            }
        }
    }
    
    open static func serializer<T: BaseMappable>(_ path: String?, object: T? = nil) -> DataResponseSerializer<T> {
        return DataResponseSerializer { request, response, data, error in
            do {
                try validate(request: request, response: response, data: data, error: error)
                let serializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
                let result = serializer.serializeResponse(request, response, data, error)
                let json: Any?
                if let path = path, path.isEmpty == false {
                    json = (result.value as AnyObject?)?.value(forKeyPath: path)
                } else {
                    json = result.value
                }
                if let mapper = Mapper<T>().map(JSONObject: json) {
                    return .success(mapper)
                }
                throw MapperError.failed
            } catch {
                return .failure(error)
            }
        }
    }
    
    @discardableResult
    open func parse<T: BaseMappable>(path: String? = nil, handler: @escaping (DataResponse<[T]>) -> Void) -> Self {
        let queue = DispatchQueue.global(qos: .default)
        return response(queue: queue, responseSerializer: DataRequest.serializer(path), completionHandler: handler)
    }
    
    @discardableResult
    open func parse<T: BaseMappable>(path: String? = nil, object: T? = nil, handler: @escaping (DataResponse<T>) -> Void) -> Self {
        let queue = DispatchQueue.global(qos: .default)
        return response(queue: queue, responseSerializer: DataRequest.serializer(path, object: object), completionHandler: handler)
    }
    
    @discardableResult
    open func parse<T: BaseMappable>(path: String? = nil, object: T? = nil) -> DataResponse<T> {
        let queue = DispatchQueue.global(qos: .default)
        var result: DataResponse<T>!
        let semaphore = DispatchSemaphore(value: 0)
        response(queue: queue, responseSerializer: DataRequest.serializer(path, object: object), completionHandler: {(response: DataResponse<T>) in
            result = response
            semaphore.signal()
        })
        _ = semaphore.wait(timeout: .distantFuture)
        return result
    }
    
    @discardableResult
    open func parse<T: BaseMappable>(path: String? = nil, object: T? = nil) -> DataResponse<[T]> {
        let queue = DispatchQueue.global(qos: .default)
        var result: DataResponse<[T]>!
        let semaphore = DispatchSemaphore(value: 0)
        response(queue: queue, responseSerializer: DataRequest.serializer(path), completionHandler: {(response: DataResponse<[T]>) in
            result = response
            semaphore.signal()
        })
        _ = semaphore.wait(timeout: .distantFuture)
        return result
    }
    
    open func responseData() -> DataResponse<Data> {
        let queue = DispatchQueue.global(qos: .default)
        var result: DataResponse<Data>!
        let semaphore = DispatchSemaphore(value: 0)
        response(queue: queue, responseSerializer: DataRequest.dataResponseSerializer(), completionHandler: {(response: DataResponse<Data>) in
            result = response
            semaphore.signal()
        })
        _ = semaphore.wait(timeout: .distantFuture)
        return result
    }
}
