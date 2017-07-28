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
    
    static func obter(id: Int) throws -> DocumentoModel {
        let url = "\(Config.restURL)/documento/obter/\(id)"
        let response: DataResponse<DocumentoModel> = try Network.request(url, method: .get, encoding: JSONEncoding.default, headers: Device.headers).parse()
        let result = response.result
        if result.isFailure {
            throw result.error!
        }
        let dataSet = result.value!
        return dataSet
    }
    
    static func justificar(model: JustificativaModel) throws -> ResultModel {
        let url = "\(Config.restURL)/documento/justificar"
        let parameters = model.dictionary
        let response: DataResponse<ResultModel> = try Network.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: Device.headers).parse()
        let result = response.result
        if result.isFailure {
            throw result.error!
        }
        let dataSet = result.value!
        return dataSet
    }
    
    static func enviar(id: Int) throws -> ArrayDataSet<DocumentoModel, DocumentoMeta> {
        let referencia = "\(id)"
        let exists = try DigitalizacaoService.existsBy(referencia: referencia, tipo: .tipificacao, status: [.enviando, .aguardando])
        let url = "\(Config.restURL)/documento/enviar/\(id)/\(exists)"
        let response: DataResponse<ArrayDataSet<DocumentoModel, DocumentoMeta>> = try Network.request(url, method: .get, encoding: JSONEncoding.default, headers: Device.headers).parse()
        let result = response.result
        if result.isFailure {
            throw result.error!
        }
        let dataSet = result.value!
        return dataSet
    }
    
    static func reenviar(id: Int) throws -> ArrayDataSet<DocumentoModel, DocumentoMeta> {
        let referencia = "\(id)"
        let exists = try DigitalizacaoService.existsBy(referencia: referencia, tipo: .tipificacao, status: [.enviando, .aguardando])
        let url = "\(Config.restURL)/documento/reenviar/\(id)/\(exists)"
        let response: DataResponse<ArrayDataSet<DocumentoModel, DocumentoMeta>> = try Network.request(url, method: .get, encoding: JSONEncoding.default, headers: Device.headers).parse()
        let result = response.result
        if result.isFailure {
            throw result.error!
        }
        let dataSet = result.value!
        return dataSet
    }
    
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
        
        static func obter(id: Int) -> Observable<DocumentoModel> {
            return Observable.create { observer in
                do {
                    let model = try DocumentoService.obter(id: id)
                    observer.onNext(model)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
                return Disposables.create()
            }
        }
        
        static func justificar(model: JustificativaModel) -> Observable<ResultModel> {
            return Observable.create { observer in
                do {
                    let result = try DocumentoService.justificar(model: model)
                    observer.onNext(result)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
                return Disposables.create()
            }
        }
        
        static func enviar(id: Int) -> Observable<ArrayDataSet<DocumentoModel, DocumentoMeta>> {
            return Observable.create { observer in
                do {
                    let dataSet = try DocumentoService.enviar(id: id)
                    observer.onNext(dataSet)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
                return Disposables.create()
            }
        }
        
        static func reenviar(id: Int) -> Observable<ArrayDataSet<DocumentoModel, DocumentoMeta>> {
            return Observable.create { observer in
                do {
                    let dataSet = try DocumentoService.reenviar(id: id)
                    observer.onNext(dataSet)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
                return Disposables.create()
            }
        }
        
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
