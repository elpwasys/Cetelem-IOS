//
//  ImageService.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 17/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation

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
}
