//
//  PesquisaService.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 09/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation

import RxSwift
import Alamofire

class PesquisaService: Service {
    
    static func dataSet() throws -> DataSet<ProcessoPagingModel, ProcessoMeta> {
        let url = "\(Config.restURL)/pesquisa/dataset"
        let response: DataResponse<DataSet<ProcessoPagingModel, ProcessoMeta>> = try Network.request(url, method: .get, encoding: JSONEncoding.default, headers: Device.headers).parse()
        let result = response.result
        if result.isFailure {
            throw result.error!
        }
        let dataSet = result.value!
        return dataSet
    }
    
    static func filtrar(model: PesquisaModel) throws -> ProcessoPagingModel {
        let url = "\(Config.restURL)/pesquisa/filtrar"
        let response: DataResponse<ProcessoPagingModel> = try Network.request(url, method: .post, parameters: model.parameters, encoding: JSONEncoding.default, headers: Device.headers).parse()
        let result = response.result
        if result.isFailure {
            throw result.error!
        }
        let model = result.value!
        return model
    }
    
    class Async {
        
        static func filtrar(model: PesquisaModel) -> Observable<ProcessoPagingModel> {
            return Observable.create { observer in
                do {
                    let model = try PesquisaService.filtrar(model: model)
                    observer.onNext(model)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
                return Disposables.create()
            }
        }
        
        static func dataSet() -> Observable<DataSet<ProcessoPagingModel, ProcessoMeta>> {
            return Observable.create { observer in
                do {
                    let dataSet = try PesquisaService.dataSet()
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
