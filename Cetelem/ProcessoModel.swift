//
//  ProcessoModel.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 09/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation
import ObjectMapper

class ProcessoModel: Model {
    
    var status: Status!
    var dataCriacao: Date!
    var tipoProcesso: TipoProcessoModel!
    
    var uploads: [UploadModel]?
    var gruposCampos: [CampoGrupoModel]?
    
    var dictionary: [String: Any]? {
        var values: [String: Any]?
        func put(_ key: String, _ value: Any?) {
            if value != nil, let text = TextUtils.text(value) {
                if values == nil {
                    values = [String: Any]()
                }
                values?[key] = text
            }
        }
        put("id", id)
        if status != nil {
            put("status", status.rawValue)
        }
        put("dataCriacao", dataCriacao)
        if tipoProcesso != nil, let element = tipoProcesso.dictionary {
            if values == nil {
                values = [String: String]()
            }
            values?["tipoProcesso"] = element
        }
        if let grupos = self.gruposCampos {
            var elements = [[String: Any]]()
            for grupo in grupos {
                if let element = grupo.dictionary {
                    elements.append(element)
                }
            }
            if !elements.isEmpty {
                if values == nil {
                    values = [String: String]()
                }
                values?["gruposCampos"] = elements
            }
        }
        return values
    }
    
    enum Status: String {
        case rascunho = "RASCUNHO"
        case emProcessamento = "EM_PROCESSAMENTO"
        case emAnalise = "EM_ANALISE"
        case pendente = "PENDENTE"
        case concluido = "CONCLUIDO"
        case cancelado = "CANCELADO"
        case concluidoAutomatico = "CONCLUIDO_AUTOMATICO"
        var key: String {
            return "Processo.Status.\(self)"
        }
        var icon: UIImage? {
            return UIImage(named: key)
        }
        var label: String {
            return TextUtils.localized(forKey: key)
        }
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        let dateTransform = DateTransformType()
        status <- map["status"]
        dataCriacao <- (map["dataCriacao"], dateTransform)
        tipoProcesso <- map["tipoProcesso"]
        gruposCampos <- map["gruposCampos"]
    }
}
