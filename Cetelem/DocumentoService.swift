//
//  DocumentoService.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 26/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation

import RxSwift
import Alamofire

class DocumentoService: Service {
    
    static func dataSet(id: Int) throws -> ArrayDataSet<DocumentoModel, DocumentoMeta> {
        let url = "\(Config.restURL)/documento/dataset/\(id)"
        let response: DataResponse<ArrayDataSet<DocumentoModel, DocumentoMeta>> = try Network.request(url, method: .get, encoding: JSONEncoding.default, headers: Device.headers).parse()
        let result = response.result
        if result.isFailure {
            throw result.error!
        }
        let dataSet = result.value!
        return dataSet
    }
    
    class Async {
        
        static func dataSet(id: Int) -> Observable<ArrayDataSet<DocumentoModel, DocumentoMeta>> {
            return Observable.create { observer in
                do {
                    let dataSet = try DocumentoService.dataSet(id: id)
                    observer.onNext(dataSet)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
                return Disposables.create()
            }
        }
    }
}
