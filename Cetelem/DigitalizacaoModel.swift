//
//  DigitalizacaoModel.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 25/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation

class DigitalizacaoModel {
    
    var id: Int!
    var tentativas: Int!
    
    var tipo: Tipo!
    var status: Status!
    
    var referencia: String!
    var mensagem: String?
    
    var dataHora: Date!
    var dataHoraEnvio: Date?
    var dataHoraRetorno: Date?
    
    var arquivos: [ArquivoModel]?
    
    enum Tipo: String {
        case documento = "DOCUMENTO"
        case tipificacao = "TIPIFICACAO"
        var key: String {
            return "Digitalizacao.Tipo.\(self)"
        }
        var label: String {
            return TextUtils.localized(forKey: key)
        }
    }
    
    enum Status: String {
        case erro = "ERRO"
        case enviado = "ENVIADO"
        case enviando = "ENVIANDO"
        case aguardando = "AGUARDANDO"
        var key: String {
            return "Digitalizacao.Status.\(self)"
        }
        var label: String {
            return TextUtils.localized(forKey: key)
        }
        var textColor: UIColor {
            return Color.white
        }
        var shadowColor: UIColor {
            switch self {
            case .erro: return Color.red900
            case .enviado: return Color.green900
            case .enviando: return Color.orange900
            case .aguardando: return Color.grey900
            }
        }
        var backgroundColor: UIColor {
            switch self {
                case .erro: return Color.red500
                case .enviado: return Color.green500
                case .enviando: return Color.orange500
                case .aguardando: return Color.grey500
            }
        }
    }
    
    static func from(_ digitalizacao: Digitalizacao) -> DigitalizacaoModel {
        let model = DigitalizacaoModel()
        model.id = digitalizacao.id
        model.tentativas = digitalizacao.tentativas
        model.tipo = Tipo(rawValue: digitalizacao.tipo)
        model.status = Status(rawValue: digitalizacao.status)
        model.referencia = digitalizacao.referencia
        model.mensagem = digitalizacao.mensagem
        model.dataHora = digitalizacao.dataHora
        model.dataHoraEnvio = digitalizacao.dataHoraEnvio
        model.dataHoraRetorno = digitalizacao.dataHoraRetorno
        model.arquivos = ArquivoModel.from(digitalizacao.arquivos)
        return model
    }
}
