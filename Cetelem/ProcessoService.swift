//
//  ProcessoService.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 10/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation

import RxSwift
import Alamofire

class ProcessoService: Service {

    static func salvar(model: ProcessoModel) throws -> ProcessoModel {
        let url = "\(Config.restURL)/processo/salvar"
        let dictionary = model.dictionary
        let response: DataResponse<ProcessoModel> = try Network.request(url, method: .post, parameters:dictionary, encoding: JSONEncoding.default, headers: Device.headers).parse()
        let result = response.result
        if result.isFailure {
            throw result.error!
        }
        let value = result.value!
        if let uploads = model.uploads {
            let referencia = "\(value.id!)"
            _ = try DigitalizacaoService.criar(referencia: referencia, tipo: .tipificacao, uploads: uploads)
            try DigitalizacaoService.digitalizar(tipo: .tipificacao, referencia: referencia)
        }
        return value
    }
    
    static func dataSet() throws -> DataSet<ProcessoModel, ProcessoMeta> {
        let url = "\(Config.restURL)/processo/dataset"
        let response: DataResponse<DataSet<ProcessoModel, ProcessoMeta>> = try Network.request(url, method: .get, encoding: JSONEncoding.default, headers: Device.headers).parse()
        let result = response.result
        if result.isFailure {
            throw result.error!
        }
        let dataSet = result.value!
        return dataSet
    }
    
    static func enviar(id: Int) throws -> DataSet<ProcessoModel, ProcessoRegraModel> {
        let referencia = "\(id)"
        let exists = try DigitalizacaoService.existsBy(referencia: referencia, tipo: .tipificacao, status: [.enviando, .aguardando])
        let url = "\(Config.restURL)/processo/enviar/\(id)/\(exists)"
        let response: DataResponse<DataSet<ProcessoModel, ProcessoRegraModel>> = try Network.request(url, method: .get, encoding: JSONEncoding.default, headers: Device.headers).parse()
        let result = response.result
        if result.isFailure {
            throw result.error!
        }
        let dataSet = result.value!
        return dataSet
    }
    
    static func reenviar(id: Int) throws -> DataSet<ProcessoModel, ProcessoRegraModel> {
        let referencia = "\(id)"
        let exists = try DigitalizacaoService.existsBy(referencia: referencia, tipo: .tipificacao, status: [.enviando, .aguardando])
        let url = "\(Config.restURL)/processo/reenviar/\(id)/\(exists)"
        let response: DataResponse<DataSet<ProcessoModel, ProcessoRegraModel>> = try Network.request(url, method: .get, encoding: JSONEncoding.default, headers: Device.headers).parse()
        let result = response.result
        if result.isFailure {
            throw result.error!
        }
        let dataSet = result.value!
        return dataSet
    }
    
    static func editar(id: Int) throws -> DataSet<ProcessoModel, ProcessoRegraModel> {
        let url = "\(Config.restURL)/processo/editar/\(id)"
        let response: DataResponse<DataSet<ProcessoModel, ProcessoRegraModel>> = try Network.request(url, method: .get, encoding: JSONEncoding.default, headers: Device.headers).parse()
        let result = response.result
        if result.isFailure {
            throw result.error!
        }
        let dataSet = result.value!
        return dataSet
    }
    
    static func tipoDataSet(id: Int) throws -> DataSet<TipoProcessoModel, TipoProcessoMeta> {
        let url = "\(Config.restURL)/processo/tipo/dataset/\(id)"
        let response: DataResponse<DataSet<TipoProcessoModel, TipoProcessoMeta>> = try Network.request(url, method: .get, encoding: JSONEncoding.default, headers: Device.headers).parse()
        let result = response.result
        if result.isFailure {
            throw result.error!
        }
        let dataSet = result.value!
        return dataSet
    }
    
    class Async {
        
        static func salvar(model: ProcessoModel) -> Observable<ProcessoModel> {
            return Observable.create { observer in
                do {
                    let model = try ProcessoService.salvar(model: model)
                    observer.onNext(model)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
                return Disposables.create()
            }
        }
        
        static func editar(id: Int) -> Observable<DataSet<ProcessoModel, ProcessoRegraModel>> {
            return Observable.create { observer in
                do {
                    let dataSet = try ProcessoService.editar(id: id)
                    observer.onNext(dataSet)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
                return Disposables.create()
            }
        }
        
        static func enviar(id: Int) -> Observable<DataSet<ProcessoModel, ProcessoRegraModel>> {
            return Observable.create { observer in
                do {
                    let dataSet = try ProcessoService.enviar(id: id)
                    observer.onNext(dataSet)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
                return Disposables.create()
            }
        }
        
        static func reenviar(id: Int) -> Observable<DataSet<ProcessoModel, ProcessoRegraModel>> {
            return Observable.create { observer in
                do {
                    let dataSet = try ProcessoService.reenviar(id: id)
                    observer.onNext(dataSet)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
                return Disposables.create()
            }
        }
                
        static func dataSet() -> Observable<DataSet<ProcessoModel, ProcessoMeta>> {
            return Observable.create { observer in
                do {
                    let dataSet = try ProcessoService.dataSet()
                    observer.onNext(dataSet)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
                return Disposables.create()
            }
        }
        
        static func tipoDataSet(id: Int) -> Observable<DataSet<TipoProcessoModel, TipoProcessoMeta>> {
            return Observable.create { observer in
                do {
                    let dataSet = try ProcessoService.tipoDataSet(id: id)
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
