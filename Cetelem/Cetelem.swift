//
//  Cetelem.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 06/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation 
import ObjectMapper
import SystemConfiguration

extension App {
    
}

extension Color {
    
    static let accent = Color.orange500
    static let primary = Color.green500
    static let primaryDark = Color.green800
}

class Usuario: Mappable {
    
    var id: Int!
    var nome: String!
    var email: String!
    
    static let updateNotificationName = Notification.Name(rawValue: "\(Usuario.self).UpdateNotificationName")
    
    static var current: Usuario? {
        get {
            var model: Usuario?
            let defaults = UserDefaults.standard
            if let id = defaults.value(forKey: id) as? Int,
                let nome = defaults.value(forKey: nome) as? String,
                let email = defaults.value(forKey: email) as? String {
                model = Usuario(id: id, nome: nome, email: email)
            }
            return model
        }
        set {
            let defaults = UserDefaults.standard
            if let model = newValue {
                defaults.set(model.id, forKey: id)
                defaults.set(model.nome, forKey: nome)
                defaults.set(model.email, forKey: email)
            } else {
                defaults.removeObject(forKey: id)
                defaults.removeObject(forKey: nome)
                defaults.removeObject(forKey: email)
            }
            NotificationCenter.default.post(name: updateNotificationName, object: newValue)
        }
    }
    
    private static let id = "\(Usuario.self).id"
    private static let nome = "\(Usuario.self).nome"
    private static let email = "\(Usuario.self).email"
    
    init(id: Int, nome: String, email: String) {
        self.id = id
        self.nome = nome
        self.email = email
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        nome <- map["nome"]
        email <- map["email"]
    }
    
    func dictionary() -> [String: String] {
        let hash:[String: String] = [
            "id": "\(id)",
            "nome": nome,
            "email": email
        ]
        return hash
    }
}


class Dispositivo: Mappable {
    
    var id: Int!
    var token: String!
    var pushToken: String!
    
    var usuario: Usuario!
    
    static let updateNotificationName = Notification.Name(rawValue: "\(Dispositivo.self).UpdateNotificationName")
    
    static var current: Dispositivo? {
        get {
            var model: Dispositivo?
            let defaults = UserDefaults.standard
            if let id = defaults.value(forKey: id) as? Int,
                let token = defaults.value(forKey: token) as? String {
                model = Dispositivo(id: id, token: token)
                if let value = defaults.value(forKey: pushToken) as? String {
                    model?.pushToken = value
                }
            }
            
            return model
        }
        set {
            let defaults = UserDefaults.standard
            if let model = newValue {
                defaults.set(model.id, forKey: id)
                defaults.set(model.token, forKey: token)
                if model.pushToken != nil {
                    defaults.set(model.pushToken, forKey: pushToken)
                }
                Usuario.current = newValue?.usuario
            } else {
                defaults.removeObject(forKey: id)
                defaults.removeObject(forKey: token)
                defaults.removeObject(forKey: pushToken)
                Usuario.current = nil
            }
            NotificationCenter.default.post(name: updateNotificationName, object: newValue)
        }
    }
    
    private static let id = "\(Dispositivo.self).id"
    private static let token = "\(Dispositivo.self).token"
    private static let pushToken = "\(Dispositivo.self).pushToken"
    
    init(id: Int, token: String) {
        self.id = id
        self.token = token
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        token <- map["token"]
        pushToken <- map["pushToken"]
        usuario <- map["usuario"]
    }
    
    func dictionary() -> [String: String] {
        var hash:[String: String] = [
            "id": "\(id)",
            "token": token
        ]
        if let pushToken = self.pushToken {
            hash["pushToken"] = pushToken
        }
        return hash
    }
}

class Config {
    static var plist: [String: Any] = {
        guard let path = Bundle.main.path(forResource: "config", ofType: "plist") else {
            fatalError("File config.plist does not exist.")
        }
        guard let dictionary = NSDictionary(contentsOfFile: path) as? [String : Any] else {
            fatalError("Failed to create Dictionary for config.plist.")
        }
        return dictionary
    }()
    static var host: String {
        return value(forKey: "Host")
    }
    static var port: String {
        return value(forKey: "Port")
    }
    static var context: String {
        return value(forKey: "ContextApp")
    }
    static var `protocol`: String {
        return value(forKey: "Protocol")
    }
    static var fileURL: String {
        let contextFile = value(forKey: "ContextFile")
        return "\(Config.baseURL)/\(contextFile)"
    }
    static var restURL: String {
        let contextRest = value(forKey: "ContextRest")
        return "\(Config.baseURL)/\(contextRest)"
    }
    static var baseURL: String {
        return "\(Config.protocol)://\(Config.host):\(Config.port)/\(Config.context)"
    }
    static func value(forKey: String) -> String {
        guard let value = plist[forKey] as? String else {
            fatalError("Could not find property '\(forKey)' in config.plist.")
        }
        return value
    }
}

extension Device {
    enum Header: String {
        case deviceSO = "Device-SO"
        case deviceToken = "Device-Token"
        case deviceModel = "Device-Model"
        case deviceWidth = "Device-Width"
        case deviceHeight = "Device-Height"
        case deviceSOVersion = "Device-SO-Version"
        case deviceAppVersion = "Device-App-Version"
    }
    static var headers: [String: String] {
        var headers = [
            Device.Header.deviceSO.rawValue: Device.so,
            Device.Header.deviceModel.rawValue: Device.model,
            Device.Header.deviceWidth.rawValue: "\(Device.width)",
            Device.Header.deviceHeight.rawValue: "\(Device.height)",
            Device.Header.deviceSOVersion.rawValue: Device.systemVersion
        ]
        if let version = Device.appVersion {
            headers[Device.Header.deviceAppVersion.rawValue] = version
        }
        if let dispositivo = Dispositivo.current {
            if dispositivo.token != nil {
                headers[Device.Header.deviceToken.rawValue] = dispositivo.token
            }
        }
        return headers
    }
}
