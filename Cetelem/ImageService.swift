//
//  ImageService.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 17/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation

import RxSwift
import Alamofire

class ImageService: Service {
    
    private static let uploadsDirectoryName = "Uploads"
    
    enum Directory {
        case uploads
        case documentos
        case temporario
        var url: URL {
            switch self {
            case .uploads:
                return Directory.documentos.url.appendingPathComponent(uploadsDirectoryName)
            case .documentos:
                return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            case .temporario:
                return URL(fileURLWithPath: NSTemporaryDirectory())
            }
        }
    }
    
    static func excluir(id: Int) throws -> ResultModel {
        let url = "\(Config.restURL)/imagem/excluir/\(id)"
        let response: DataResponse<ResultModel> = try Network.request(url, method: .get, encoding: JSONEncoding.default, headers: Device.headers).parse()
        let result = response.result
        if result.isFailure {
            throw result.error!
        }
        let model = result.value!
        return model
    }
    
    static func move(origin: URL, destination: URL) throws {
        let manager = FileManager.default
        try manager.moveItem(at: origin, to: destination)
    }
    
    static func create(directory: Directory) throws -> Directory {
        if directory != .documentos && directory != .temporario {
            try FileManager.default.createDirectory(at: directory.url, withIntermediateDirectories: true, attributes: nil)
        }
        return directory
    }
    
    class Async {
        
        static func excluir(id: Int) -> Observable<ResultModel> {
            return Observable.create { observer in
                do {
                    let model = try ImageService.excluir(id: id)
                    observer.onNext(model)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
                return Disposables.create()
            }
        }
    }
}
