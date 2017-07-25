//
//  DispositivoService.swift
//  ClubMesa
//
//  Created by Everton Luiz Pascke on 16/04/17.
//  Copyright © 2017 Everton Luiz Pascke. All rights reserved.
//

import Foundation

import RxSwift
import Alamofire

class DispositivoService: Service {
    
    static func autenticar(login: String, senha: String) throws -> Dispositivo {
        let url = "\(Config.restURL)/dispositivo/autenticar"
        let parameters = [
            "login": login,
            "senha": senha
        ];
        let response: DataResponse<Dispositivo> = try Network.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: Device.headers).parse()
        let result = response.result
        if result.isFailure {
            throw result.error!
        }
        let dispositivo = result.value!
        return dispositivo
    }
    
    class Async {
        static func autenticar(login: String, senha: String) -> Observable<Dispositivo> {
            return Observable.create { observer in
                do {
                    let dispositivo = try DispositivoService.autenticar(login: login, senha: senha)
                    observer.onNext(dispositivo)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
                return Disposables.create()
            }
        }
    }
}
