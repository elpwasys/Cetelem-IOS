//
//  DigitalizacaoService.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 25/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation

import RxSwift
import Alamofire
import RealmSwift

class DigitalizacaoService: Service {
    
    static func existsBy(referencia: String, tipo: DigitalizacaoModel.Tipo, status: [DigitalizacaoModel.Status]? = nil) throws -> Bool {
        var names = [String]()
        if let values = status {
            for value in values {
                names.append(value.rawValue)
            }
        }
        let realm = try Realm()
        var results = realm.objects(Digitalizacao.self).filter("referencia = %@ and tipo = %@", referencia, tipo.rawValue)
        if !names.isEmpty {
            results = results.filter("status in %@", names)
        }
        return !results.isEmpty
    }
    
    static func getBy(referencia: String, tipo: DigitalizacaoModel.Tipo, status: DigitalizacaoModel.Status? = nil) throws -> DigitalizacaoModel? {
        let realm = try Realm()
        var results = realm.objects(Digitalizacao.self).filter("referencia = %@ and tipo = %@", referencia, tipo.rawValue)
        if status != nil {
            results = results.filter("status = %@", status!.rawValue)
        }
        if let digitalizacao = results.first {
            return DigitalizacaoModel.from(digitalizacao)
        }
        return nil
    }
    
    static func criar(referencia: String, tipo: DigitalizacaoModel.Tipo, uploads: [UploadModel]) throws {
        if !uploads.isEmpty {
            let realm = try Realm()
            // REGISTRO DE DIGITALIZACAO
            let predicate = NSPredicate(format: "referencia = %@ and tipo = %@", referencia, tipo.rawValue)
            var digitalizacao = realm.objects(Digitalizacao.self).filter(predicate).first
            if digitalizacao != nil {
                let status = DigitalizacaoModel.Status(rawValue: digitalizacao!.status)
                if status == .enviando {
                    throw Trouble.any("Aguarde a digitalizacao anterior terminar para poder enviar outra.")
                }
            } else {
                digitalizacao = Digitalizacao()
                digitalizacao!.id = try RealmService.nextId(Digitalizacao.self)
                digitalizacao!.tipo = tipo.rawValue
                digitalizacao!.dataHora = Date()
                digitalizacao!.tentativas = 0
                digitalizacao!.referencia = referencia
            }
            digitalizacao!.status = DigitalizacaoModel.Status.aguardando.rawValue
            digitalizacao!.mensagem = nil
            digitalizacao!.dataHoraEnvio = nil
            digitalizacao!.dataHoraRetorno = nil
            // REGISTROS DE ARQUIVO DA DIGITALIZACAO
            var paths = [String: String]()
            let directory = try ImageService.create(directory: .uploads).url
            for upload in uploads {
                let url = URL(fileURLWithPath: upload.path)
                let path = directory.appendingPathComponent(url.lastPathComponent).path
                var arquivo = realm.objects(Arquivo.self).filter(NSPredicate(format: "caminho = %@", path)).first
                if arquivo == nil {
                    arquivo = Arquivo()
                    arquivo!.id = try RealmService.nextId(Arquivo.self)
                    arquivo!.caminho = path
                    arquivo!.digitalizacao = digitalizacao
                    digitalizacao!.arquivos.append(arquivo!)
                    paths[upload.path] = path
                }
            }
            try realm.write {
                realm.add(digitalizacao!, update: true)
                // MOVE O ARQUIVO
                for (key, value) in paths {
                    let origin = URL(fileURLWithPath: key)
                    let destination = URL(fileURLWithPath: value)
                    try ImageService.move(origin: origin, destination: destination)
                }
            }
        }
    }
    
    static func digitalizar(tipo: DigitalizacaoModel.Tipo, referencia: String) throws {
        print("Iniciando digitalizacao \(referencia)...")
        // OBTEM A DIGITALIZACAO
        guard let model = try find(tipo: tipo, referencia: referencia, status: [ .erro, .aguardando ]) else {
            return
        }
        if let arquivos = model.arquivos {
            // ATUALIZA DIGITALIZACAO PARA ENVIANDO
            try update(id: model.id, status: .enviando)
            // FAZ O UPLOAD DAS IMAGENS
            try upload(tipo: tipo, referencia: referencia, arquivos: arquivos) { (success, error) in
                if success {
                    do {
                        try delete(id: model.id)
                        try update(id: model.id, status: .enviado)
                        print("Sucesso na digitalizacao \(referencia)...")
                    } catch {
                        update(id: model.id, referencia: referencia, error: error)
                    }
                } else {
                    update(id: model.id, referencia: referencia, error: error!)
                }
            }
        }
    }
    
    private static func find(tipo: DigitalizacaoModel.Tipo, referencia: String, status: [DigitalizacaoModel.Status]) throws -> DigitalizacaoModel? {
        var names = [String]()
        for val in status {
            names.append(val.rawValue)
        }
        let joined = names.joined(separator: ", ")
        print("Buscando digitalizacao \(referencia) status [\(joined)]...")
        let realm = try Realm()
        let predicate = NSPredicate(format: "referencia = %@ and tipo = %@ and status in %@", referencia, tipo.rawValue, names)
        if let digitalizacao = realm.objects(Digitalizacao.self).filter(predicate).first {
            return DigitalizacaoModel.from(digitalizacao)
        }
        return nil
    }
    
    private static func delete(id: Int) throws {
        print("Listando registros de arquivos da digitalizacao para excluir...")
        let realm = try Realm()
        let predicate = NSPredicate(format: "id = %ld", id)
        let digitalizacao = realm.objects(Digitalizacao.self).filter(predicate).first!
        let arquivos = digitalizacao.arquivos
        if !arquivos.isEmpty {
            var caminhos = [String]()
            for arquivo in arquivos {
                caminhos.append(arquivo.caminho)
            }
            do {
                print("Excluindo registros de arquivos...")
                try realm.write {
                    realm.delete(arquivos)
                    print("Sucesso na exclusao dos registros de arquivos.")
                    print("Iniciando exclusao dos arquivos fisicos...")
                    for caminho in caminhos {
                        if FileManager.default.fileExists(atPath: caminho) {
                            do {
                                try FileManager.default.removeItem(atPath: caminho)
                                print("Arquivo '\(caminho)' excluido com sucesso.")
                            } catch {
                                print("Falha ao excluir arquivo '\(caminho)'. \(error.localizedDescription).")
                            }
                        }
                    }
                }
            } catch {
                print("Falha ao excluir registros de arquivos. \(error.localizedDescription).")
            }
        }
    }
    
    private static func update(id: Int, status: DigitalizacaoModel.Status, mensagem: String? = nil) throws {
        print("Atualizando status da digitalizacao para \(status.rawValue)...")
        do {
            let realm = try Realm()
            let predicate = NSPredicate(format: "id = %ld", id)
            let digitalizacao = realm.objects(Digitalizacao.self).filter(predicate).first!
            try realm.write {
                digitalizacao.status = status.rawValue
                digitalizacao.mensagem = mensagem
                if status == .enviando {
                    let tentativas = digitalizacao.tentativas
                    digitalizacao.tentativas = tentativas + 1
                    digitalizacao.dataHoraEnvio = Date()
                    print("Tentativa da digitalizacao incrementada de \(tentativas) para \(digitalizacao.tentativas).")
                } else if status == .erro || status == .enviado {
                    digitalizacao.dataHoraRetorno = Date()
                }
                print("Sucesso na atualizacao da digitalizacao.")
            }
        } catch {
            print("Falha na atualizacao da digitalizacao. \(error.localizedDescription)")
            throw error
        }
    }
    
    private static func update(id: Int, referencia: String, error: Error) {
        var mensagem = error.localizedDescription
        if error is Trouble {
            let trouble = error as! Trouble
            mensagem = trouble.description
        }
        print("Erro na digitalizacao \(referencia). \(mensagem)")
        try? update(id: id, status: .erro, mensagem: mensagem)
    }
    
    private static func upload(tipo: DigitalizacaoModel.Tipo, referencia: String, arquivos: [ArquivoModel], completion: @escaping (Bool, Error?) -> Void) throws {
        print("Iniciando o upload dos arquivos da digitalizacao \(referencia)....")
        if !arquivos.isEmpty {
            print("Listando imagens para enviar...")
            var urls = [URL]()
            for arquivo in arquivos {
                let path = arquivo.caminho
                if FileManager.default.fileExists(atPath: path) {
                    let url = URL(fileURLWithPath: path)
                    urls.append(url)
                    print("Imagem '\(path)' adicionado no multipart.")
                } else {
                    print("Imagem '\(path)' nao encontrada!")
                }
            }
            if urls.isEmpty {
                completion(true, nil)
            } else {
                let url = "\(Config.restURL)/digitalizacao/digitalizar/\(tipo.rawValue.lowercased())/\(referencia)"
                try Network.upload(
                    multipartFormData: { multipart in
                        for url in urls {
                            multipart.append(url, withName: "files")
                        }
                    },
                    to: url,
                    method: .post,
                    headers: Device.headers,
                    encodingCompletion: { encondingResult in
                        print("Extraindo resultado da codificacao do multipart...")
                        switch encondingResult {
                        case .success(let request,  _, _):
                            print("Enviando imagens...")
                            request.parse(handler: {(response: DataResponse<ResultModel>) in
                                print("Extraindo resposta...")
                                if response.result.isSuccess {
                                    let model = response.result.value!
                                    if model.isSuccess {
                                        print("Sucesso no envio das imagens.")
                                        completion(true, nil)
                                    } else {
                                        print("Erro no envio das imagens.")
                                        completion(false, Trouble.any(model.message ?? "Erro no servidor!"))
                                    }
                                } else {
                                    print("Falha no envio das imagens.")
                                    completion(false, Trouble.any("Falha no resultado da resposta!"))
                                }
                            })
                        case .failure(let error):
                            print("Falha na codificacao das imagens.")
                            completion(false, error)
                        }
                    }
                )
            }
        }
    }
    
    class Async {
        
        static func digitalizar(tipo: DigitalizacaoModel.Tipo, referencia: String) -> Observable<Void> {
            return Observable.create { observer in
                do {
                    try DigitalizacaoService.digitalizar(tipo: tipo, referencia: referencia)
                    observer.onNext()
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
                return Disposables.create()
            }
        }
        
        static func getBy(referencia: String, tipo: DigitalizacaoModel.Tipo) -> Observable<DigitalizacaoModel?> {
            return Observable.create { observer in
                do {
                    let model = try DigitalizacaoService.getBy(referencia: referencia, tipo: tipo)
                    observer.onNext(model)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
                return Disposables.create()
            }
        }
        
        static func existsBy(referencia: String, tipo: DigitalizacaoModel.Tipo, status: [DigitalizacaoModel.Status]? = nil) -> Observable<Bool> {
            return Observable.create { observer in
                do {
                    let exists = try DigitalizacaoService.existsBy(referencia: referencia, tipo: tipo, status: status)
                    observer.onNext(exists)
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
