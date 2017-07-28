//
//  ProcessoDetalheViewController.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 25/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit
import Floaty
import MaterialComponents

class ProcessoDetalheViewController: DrawerViewController {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imagensButton: UIBarButtonItem!
    
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var tipoProcessoLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    
    var id:Int? // ID DO PROCESSO
    
    fileprivate var grupos = [CampoGrupoModel]()
    
    fileprivate var regra: ProcessoRegraModel?
    fileprivate var processo: ProcessoModel?
    fileprivate var digitalizacao: DigitalizacaoModel?
    
    // FLOATING ACTION BUTTONS
    fileprivate var menuFloatButton: Floaty!
    fileprivate var editarFloatButton: FloatyItem!
    fileprivate var salvarFloatButton: FloatyItem!
    fileprivate var enviarFloatButton: FloatyItem!
    fileprivate var reenviarFloatButton: FloatyItem!
    
    fileprivate var isEditable = false {
        didSet {
            tableView.reloadData()
            salvarFloatButton.isHidden = !isEditable
        }
    }
    
    fileprivate var isValid: Bool {
        var valid = true
        for (section, grupo) in grupos.enumerated() {
            if let campos = grupo.campos {
                for (row, _) in campos.enumerated() {
                    let indexPath = IndexPath(row: row, section: section)
                    if let cell = tableView.cellForRow(at: indexPath) as? CampoTableViewCell {
                        if !cell.isValid {
                            valid = false
                        }
                    }
                }
            }
        }
        return valid
    }
    
    fileprivate var values: [CampoGrupoModel] {
        var values = [CampoGrupoModel]()
        for (section, grupo) in self.grupos.enumerated() {
            if let campos = grupo.campos {
                let value = CampoGrupoModel()
                value.id = grupo.id
                value.nome = grupo.nome
                for (row, campo) in campos.enumerated() {
                    let indexPath = IndexPath(row: row, section: section)
                    if let cell = tableView.cellForRow(at: indexPath) as? CampoTableViewCell {
                        let model = CampoModel()
                        model.id = campo.id
                        model.nome = campo.nome
                        model.valor = cell.value
                        value.add(model)
                    }
                }
                values.append(value)
            }
        }
        return values
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preapare()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let id = self.id {
            startAsyncEditar(id)
        }
    }
    
    @IBAction func onInfoTapped() {
        verificarDigitalizacao()
    }
    
    @IBAction func onImageTapped(_ sender: UIBarButtonItem) {
        pushDocumentoListaViewController()
    }
}

// MARK: Custom
extension ProcessoDetalheViewController {
    
    fileprivate func preapare() {
        prepareTopView()
        prepareTableView()
        prepareFloatButtons()
    }
    
    fileprivate func prepareTopView() {
        topView.borderBottomWith(color: Color.grey300, width: 1)
    }
    
    fileprivate func prepareTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: RadioTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: RadioTableViewCell.reusableCellIdentifier)
        tableView.register(UINib(nibName: SwitchTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: SwitchTableViewCell.reusableCellIdentifier)
        tableView.register(UINib(nibName: TextFieldTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: TextFieldTableViewCell.reusableCellIdentifier)
        tableView.register(UINib(nibName: TableHeaderView.nibName, bundle: nil), forHeaderFooterViewReuseIdentifier: TableHeaderView.reusableCellIdentifier)
    }
    
    fileprivate func clear() {
        ViewUtils.text(nil, for: idLabel)
        ViewUtils.text(nil, for: dataLabel)
        ViewUtils.text(nil, for: statusLabel)
        ViewUtils.text(nil, for: tipoProcessoLabel)
        statusImageView.image = nil
        menuFloatButton.isHidden = true
        for item in menuFloatButton.items {
            item.isHidden = true
        }
    }
    
    fileprivate func populate() {
        clear()
        if let processo = self.processo {
            ViewUtils.text(processo.id, for: idLabel)
            ViewUtils.text(processo.dataCriacao, for: dataLabel)
            ViewUtils.text(processo.status.label, for: statusLabel)
            ViewUtils.text(processo.tipoProcesso.nome, for: tipoProcessoLabel)
            statusImageView.image = processo.status.icon
            grupos = processo.gruposCampos ?? [CampoGrupoModel]()
            tableView.reloadData()
            if processo.status != .pendente {
                verificarErroDigitalizacao()
            } else {
                /*
                 let action = MDCSnackbarMessageAction()
                 action.title = TextUtils.localized(forKey: "Label.Abrir")
                 action.handler = {() in
                 self.pushDocumentoListaViewController()
                 }
                 let snackbar = MDCSnackbarMessage()
                 snackbar.text = TextUtils.localized(forKey: "Message.ProcessoPendente")
                 snackbar.action = action
                 snackbar.buttonTextColor = Color.accent
                 MDCSnackbarManager.show(snackbar)
                 
                 */
                let title = TextUtils.localized(forKey: "Label.Abrir")
                let message = TextUtils.localized(forKey: "Message.ProcessoPendente")
                
                showSnackbar(title: title, message: message, handler: { 
                    self.pushDocumentoListaViewController()
                })
                
            }
        }
        if let regra = self.regra {
            salvarFloatButton.isHidden = !isEditable
            editarFloatButton.isHidden = !regra.podeEditar
            enviarFloatButton.isHidden = !regra.podeEnviar && !regra.hasAnyPendencia()
            reenviarFloatButton.isHidden = !regra.podeResponderPendencia && !regra.hasAnyPendencia()
            for item in menuFloatButton.items {
                if !item.isHidden {
                    menuFloatButton.isHidden = false
                    break
                }
            }
        }
    }
    
    fileprivate func pushDocumentoListaViewController() {
        let controller = UIStoryboard.viewController("Menu", identifier: "Scene.Documento.Lista") as! DocumentoListaViewController
        controller.id = id
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    fileprivate func prepareFloatButtons() {
        if menuFloatButton == nil {
            menuFloatButton = Floaty()
            menuFloatButton.isHidden = true
            menuFloatButton.plusColor = Color.white
            menuFloatButton.buttonColor = Color.red500
            menuFloatButton.overlayColor = Color.white.withAlphaComponent(0.7)
            menuFloatButton.animationSpeed = 0.05
            // SALVAR
            salvarFloatButton = FloatyItem()
            salvarFloatButton.icon = Icon.saveWhite
            salvarFloatButton.buttonColor = Color.primary
            salvarFloatButton.title = TextUtils.localized(forKey: "Label.Salvar")
            salvarFloatButton.handler = { item in
                self.onSalvarTapped()
            }
            menuFloatButton.addItem(item: salvarFloatButton)
            // ENVIAR
            enviarFloatButton = FloatyItem()
            enviarFloatButton.icon = Icon.sendWhite
            enviarFloatButton.buttonColor = Color.primary
            enviarFloatButton.title = TextUtils.localized(forKey: "Label.Enviar")
            enviarFloatButton.handler = { item in
                self.onEnviarTapped()
            }
            menuFloatButton.addItem(item: enviarFloatButton)
            // REENVIAR
            reenviarFloatButton = FloatyItem()
            reenviarFloatButton.icon = Icon.sendWhite
            reenviarFloatButton.buttonColor = Color.primary
            reenviarFloatButton.title = TextUtils.localized(forKey: "Label.Reenviar")
            reenviarFloatButton.handler = { item in
                self.onReenviarTapped()
            }
            menuFloatButton.addItem(item: reenviarFloatButton)
            // EDITAR
            editarFloatButton = FloatyItem()
            editarFloatButton.icon = Icon.modeEditWhite
            editarFloatButton.buttonColor = Color.accent
            editarFloatButton.title = TextUtils.localized(forKey: "Label.Editar")
            editarFloatButton.handler = { item in
                self.onEditarTapped()
            }
            menuFloatButton.addItem(item: editarFloatButton)
            // COMMONS SETTINGS ITEMS
            for item in menuFloatButton.items {
                item.isHidden = true
                item.titleColor = Color.black
                item.titleShadowColor = Color.white.withAlphaComponent(0)
            }
            self.view.addSubview(menuFloatButton)
        }
    }
    
    fileprivate func onSalvarTapped() {
        salvar()
    }
    
    fileprivate func onEnviarTapped() {
        let alert = Alert.create(view: revealViewController().view)
        alert.title = TextUtils.localized(forKey: "Label.Enviar")
        alert.message = TextUtils.localized(forKey: "Message.EnviarProcesso")
        alert.completionHandler = { answer in
            alert.hide()
            if answer {
                self.enviar()
            }
        }
        alert.show()
    }
    
    fileprivate func onReenviarTapped() {
        let alert = Alert.create(view: revealViewController().view)
        alert.title = TextUtils.localized(forKey: "Label.Reenviar")
        alert.message = TextUtils.localized(forKey: "Message.ReenviarProcesso")
        alert.completionHandler = { answer in
            alert.hide()
            if answer {
                self.reenviar()
            }
        }
        alert.show()
    }
    
    fileprivate func onEditarTapped() {
        if !self.isEditable {
            let alert = Alert.create(view: revealViewController().view)
            alert.title = TextUtils.localized(forKey: "Label.Editar")
            alert.message = TextUtils.localized(forKey: "Message.EditarProcesso")
            alert.completionHandler = { answer in
                alert.hide()
                self.isEditable = answer
            }
            alert.show()
        } else {
            self.isEditable = false
        }
    }
    
    fileprivate func salvar() {
        if isValid {
            let processo = ProcessoModel()
            processo.id = id
            processo.gruposCampos = values
            startAsyncSalvar(processo)
        } else {
            let message = App.Message()
            message.theme = .warning
            message.presentationStyle = .bottom
            message.content = TextUtils.localized(forKey: "Message.FormularioInvalido")
            message.show(self)
        }
    }
    
    fileprivate func enviar() {
        if let id = self.id {
            startAsyncEnviar(id)
        }
    }
    
    fileprivate func reenviar() {
        if let id = self.id {
            startAsyncReenviar(id)
        }
    }
    
    fileprivate func digitalizar() {
        if let id = self.id {
            startAsyncDigitalizar(id)
        }
    }
    
    fileprivate func verificarDigitalizacao() {
        if let id = self.id {
            startAsyncVerificarDigitalizacao(id)
        }
    }
    
    fileprivate func verificarErroDigitalizacao() {
        if let id = self.id {
            startAsyncVerificarErroDigitalizacao(id)
        }
    }
}

// MARK: UITableViewDelegate
extension ProcessoDetalheViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let grupo = grupos[section]
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: TableHeaderView.reusableCellIdentifier) as! TableHeaderView
        header.prepare(grupo.nome)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = TextFieldTableViewCell.height
        let campo = grupos[indexPath.section].campos![indexPath.row]
        if campo.tipo == .radio {
            let opcoes = campo.opcoes
            if SwitchTableViewCell.isSwitch(opcoes) {
                height = SwitchTableViewCell.height
            } else {
                let count = opcoes?.components(separatedBy: ",").count ?? 0
                height = RadioTableViewCell.height(count: count)
            }
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return TableHeaderView.height
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? TableHeaderView {
            header.contentView.backgroundColor = UIColor.white
        }
    }
}

// MARK: UITableViewDataSource
extension ProcessoDetalheViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.grupos.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return grupos[section].campos?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let campo = grupos[indexPath.section].campos![indexPath.row]
        var reusableCellIdentifier = TextFieldTableViewCell.reusableCellIdentifier
        if campo.tipo == .radio {
            reusableCellIdentifier = RadioTableViewCell.reusableCellIdentifier
            if SwitchTableViewCell.isSwitch(campo.opcoes) {
                reusableCellIdentifier = SwitchTableViewCell.reusableCellIdentifier
            }
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: reusableCellIdentifier, for: indexPath) as! CampoTableViewCell
        cell.prepare(campo)
        cell.isEnabled = isEditable
        return cell
    }
}

// MARK: Asynchronous Completed Methods
extension ProcessoDetalheViewController {
    
    fileprivate func asyncDigitalizarCompleted() {
        let content = TextUtils.localized(forKey: "Message.ProcessoEnviadoSucesso")
        showMessage(content: content, theme: .success)
    }
    
    fileprivate func asyncSalvarCompleted(_ model: ProcessoModel) {
        processo = model
        let content = TextUtils.localized(forKey: "Message.ProcessoSalvoSucesso")
        showMessage(content: content, theme: .success)
    }
    
    fileprivate func asyncEditarCompleted(_ dataSet: DataSet<ProcessoModel, ProcessoRegraModel>) {
        regra = dataSet.meta
        processo = dataSet.data
        populate()
    }
    
    fileprivate func asyncEnviarCompleted(_ dataSet: DataSet<ProcessoModel, ProcessoRegraModel>) {
        regra = dataSet.meta
        processo = dataSet.data
        populate()
        let content = TextUtils.localized(forKey: "Message.ProcessoEnviadoSucesso")
        showMessage(content: content, theme: .success)
    }
    
    fileprivate func asyncReenviarCompleted(_ dataSet: DataSet<ProcessoModel, ProcessoRegraModel>) {
        regra = dataSet.meta
        processo = dataSet.data
        populate()
        let content = TextUtils.localized(forKey: "Message.ProcessoReenviadoSucesso")
        showMessage(content: content, theme: .success)
    }
    
    fileprivate func asyncVerificarErroDigitalizacaoCompleted(_ exists: Bool) {
        if exists {
            let action = MDCSnackbarMessageAction()
            action.title = TextUtils.localized(forKey: "Label.Abrir")
            action.handler = {() in
                self.verificarDigitalizacao()
            }
            let snackbar = MDCSnackbarMessage()
            snackbar.text = TextUtils.localized(forKey: "Message.ErroDigitalizacao")
            snackbar.action = action
            snackbar.buttonTextColor = Color.accent
            MDCSnackbarManager.show(snackbar)
        }
    }
    
    fileprivate func asyncVerificarDigitalizacaoCompleted(_ model: DigitalizacaoModel?) {
        digitalizacao = model
        if let digitalizacao = self.digitalizacao {
            let dialog = DigitalizacaoDialog.create(model: digitalizacao, view: revealViewController().view)
            dialog.completionHandler = { answer in
                dialog.hide()
                if answer {
                    self.digitalizar()
                }
            }
            dialog.show()
        } else {
            let message = App.Message()
            message.layout = .StatusLine
            message.backgroundColor = Color.black
            message.foregroundColor = Color.white
            message.duration = .seconds(seconds: 1)
            message.content = TextUtils.localized(forKey: "Message.SemInfoDigitalizacao")
            message.show()
        }
    }
}

// MARK: Asynchronous Methods
extension ProcessoDetalheViewController {
    
    fileprivate func startAsyncEditar(_ id: Int) {
        self.showActivityIndicator()
        let observable = ProcessoService.Async.editar(id: id)
        prepare(for: observable)
            .subscribe(
                onNext: { dataSet in
                    self.asyncEditarCompleted(dataSet)
                },
                onError: { error in
                    self.hideActivityIndicator()
                    self.handle(error)
                },
                onCompleted: {
                    self.hideActivityIndicator()
                }
            ).addDisposableTo(disposableBag)
    }
    
    fileprivate func startAsyncEnviar(_ id: Int) {
        self.showActivityIndicator()
        let observable = ProcessoService.Async.enviar(id: id)
        prepare(for: observable)
            .subscribe(
                onNext: { dataSet in
                    self.asyncEnviarCompleted(dataSet)
                },
                onError: { error in
                    self.hideActivityIndicator()
                    self.handle(error)
                },
                onCompleted: {
                    self.hideActivityIndicator()
                }
            ).addDisposableTo(disposableBag)
    }
    
    fileprivate func startAsyncReenviar(_ id: Int) {
        self.showActivityIndicator()
        let observable = ProcessoService.Async.reenviar(id: id)
        prepare(for: observable)
            .subscribe(
                onNext: { dataSet in
                    self.asyncReenviarCompleted(dataSet)
                },
                onError: { error in
                    self.hideActivityIndicator()
                    self.handle(error)
                },
                onCompleted: {
                    self.hideActivityIndicator()
                }
            ).addDisposableTo(disposableBag)
    }
    
    fileprivate func startAsyncSalvar(_ model: ProcessoModel) {
        self.showActivityIndicator()
        let observable = ProcessoService.Async.salvar(model: model)
        prepare(for: observable)
            .subscribe(
                onNext: { model in
                    self.asyncSalvarCompleted(model)
                },
                onError: { error in
                    self.hideActivityIndicator()
                    self.handle(error)
                },
                onCompleted: {
                    self.hideActivityIndicator()
                }
            ).addDisposableTo(disposableBag)
    }
    
    fileprivate func startAsyncDigitalizar(_ id: Int) {
        let referencia = "\(id)"
        let observable = DigitalizacaoService.Async.digitalizar(tipo: .tipificacao, referencia: referencia)
        prepare(for: observable).subscribe(
            onNext: {
                self.asyncDigitalizarCompleted()
            },
            onError: { error in
                self.handle(error)
            }
        ).addDisposableTo(disposableBag)
    }
    
    fileprivate func startAsyncVerificarDigitalizacao(_ id: Int) {
        let referencia = "\(id)"
        let observable = DigitalizacaoService.Async.getBy(referencia: referencia, tipo: .tipificacao)
        prepare(for: observable).subscribe(
            onNext: { model in
                self.asyncVerificarDigitalizacaoCompleted(model)
            },
            onError: { error in
                self.handle(error)
            }
        ).addDisposableTo(disposableBag)
    }
    
    fileprivate func startAsyncVerificarErroDigitalizacao(_ id: Int) {
        let referencia = "\(id)"
        let observable = DigitalizacaoService.Async.existsBy(referencia: referencia, tipo: .tipificacao, status: [.erro])
        prepare(for: observable).subscribe(
            onNext: { exists in
                self.asyncVerificarErroDigitalizacaoCompleted(exists)
            },
            onError: { error in
                self.handle(error)
            }
        ).addDisposableTo(disposableBag)
    }
}
