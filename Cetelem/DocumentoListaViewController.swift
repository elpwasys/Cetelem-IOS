//
//  DocumentoListaViewController.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 26/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit

class DocumentoListaViewController: CetelemViewController {

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var enviarButton: RoundButton!
    @IBOutlet weak var reenviarButton: RoundButton!

    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    var id: Int?
    
    fileprivate var paths = [String]()
    fileprivate var opcionais = [DocumentoModel]()
    fileprivate var obrigatorios = [DocumentoModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepare()
        carregar()
    }
    
    override func showActivityIndicator() {
        if let controller = revealViewController() {
            App.Loading.shared.show(view: controller.view)
        } else {
            super.showActivityIndicator()
        }
    }
    
    @IBAction func onEnviarTapped() {
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
    
    @IBAction func onReenviarTapped() {
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

    @IBAction func onCameraTapped(_ sender: UIBarButtonItem) {
        presentSnapViewController()
    }
    
    @IBAction func onRefreshTapped(_ sender: UIBarButtonItem) {
        carregar()
    }
}

// MARK: Common
extension DocumentoListaViewController {
    
    fileprivate func clear() {
        enviarButton.isHidden = true
        reenviarButton.isHidden = true
        cameraButton.isEnabled = false
        opcionais.removeAll()
        obrigatorios.removeAll()
        tableView.reloadData()
    }
    
    fileprivate func prepare() {
        prepareTableView()
    }
    
    fileprivate func prepareTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: DocumentoTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: DocumentoTableViewCell.reusableCellIdentifier)
        tableView.register(UINib(nibName: TableHeaderView.nibName, bundle: nil), forHeaderFooterViewReuseIdentifier: TableHeaderView.reusableCellIdentifier)
    }
    
    fileprivate func presentSnapViewController() {
        let url = ImageService.Directory.temporario.url
        let controller = SnapViewController.create(url: url, paths: paths, with: self)
        self.present(controller, animated: true, completion: nil)
    }
    
    fileprivate func salvar() {
        if !paths.isEmpty, let id = self.id {
            var uploads = [UploadModel]()
            for path in paths {
                uploads.append(UploadModel(path))
            }
            startAsyncCriar(id, uploads)
        }
    }
    
    fileprivate func enviar() {
        if let id = self.id {
            self.startAsyncEnviar(id)
        }
    }
    
    fileprivate func reenviar() {
        if let id = self.id {
            self.startAsyncReenviar(id)
        }
    }
    
    fileprivate func carregar() {
        if let id = self.id {
            startAsyncDataSet(id)
        }
    }
    
    fileprivate func popular(_ dataSet: ArrayDataSet<DocumentoModel, DocumentoMeta>) {
        
        cameraButton.isEnabled = false
        
        enviarButton.isHidden = true
        reenviarButton.isHidden = true
        
        if let meta = dataSet.meta {
            if let regra = meta.regra {
                cameraButton.isEnabled = regra.podeDigitalizar
                if (regra.podeEnviar && !regra.hasAnyPendencia()) {
                    enviarButton.isHidden = false
                }
                if (regra.podeResponderPendencia && !regra.hasAnyPendencia()) {
                    reenviarButton.isHidden = false
                }
            }
        }
        
        opcionais.removeAll()
        obrigatorios.removeAll()
        
        if let documentos = dataSet.data {
            for documento in documentos {
                if documento.obrigatorio {
                    obrigatorios.append(documento)
                } else {
                    opcionais.append(documento)
                }
                tableView.reloadData()
            }
        }
    }
    
    fileprivate func documentoBy(indexPath: IndexPath) -> DocumentoModel {
        let documento: DocumentoModel
        if indexPath.section == 0 {
            documento = obrigatorios[indexPath.row]
        } else {
            documento = opcionais[indexPath.row]
        }
        return documento
    }
}

// MARK: SnapDelegate
extension DocumentoListaViewController: SnapDelegate {
    
    func didSnapOk(_ paths: [String], from controller: SnapViewController) {
        controller.dismiss(animated: true) {
            self.paths = paths
            if !self.paths.isEmpty {
                self.salvar()
            }
        }
    }
    
    func didSnapCancel(_ paths: [String], from controller: SnapViewController) {
        controller.dismiss(animated: true) {
            self.paths = paths
        }
    }
}

// MARK: UITableViewDelegate
extension DocumentoListaViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? TableHeaderView {
            header.contentView.backgroundColor = UIColor.white
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var height: CGFloat = 0
        if (section == 0 && !obrigatorios.isEmpty) || (section == 1 && !opcionais.isEmpty) {
            height = TableHeaderView.height
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let documento = documentoBy(indexPath: indexPath)
        return documento.status == .pendente ? DocumentoTableViewCell.totalHeight : DocumentoTableViewCell.detalheHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let nome: String
        if section == 0 {
            nome = TextUtils.localized(forKey: "Label.Obrigatorios")
        } else {
            nome = TextUtils.localized(forKey: "Label.Opcionais")
        }
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: TableHeaderView.reusableCellIdentifier) as! TableHeaderView
        header.prepare(nome)
        return header
    }
}

// MARK: UITableViewDataSource
extension DocumentoListaViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return obrigatorios.count
        } else {
            return opcionais.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DocumentoTableViewCell.reusableCellIdentifier, for: indexPath) as! DocumentoTableViewCell
        let documento = documentoBy(indexPath: indexPath)
        cell.prepare(documento, delegate: self)
        return cell
    }
}

extension DocumentoListaViewController: DocumentoTableViewCellDelegate {
    
    func onJustificarTapped(cell: DocumentoTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let documento = documentoBy(indexPath: indexPath)
            let view = revealViewController().view!
            let dialog = PendenciaDialog.create(model: documento, view: view)
            dialog.completionHandler = { aswner, justificativa in
                if aswner {
                    dialog.hide()
                }
            }
            dialog.show()
        }
    }
}

// MARK: Asynchronous Completed Methods
extension DocumentoListaViewController {
    
    fileprivate func asyncCriarCompleted(_ model: DigitalizacaoModel) {
        do {
            try DigitalizacaoService.digitalizar(tipo: .tipificacao, referencia: model.referencia)
            let content = TextUtils.localized(forKey: "Message.ProcessoSalvoSucesso")
            showMessage(content: content, theme: .success)
        } catch {
            handle(error)
        }
    }
    
    fileprivate func asyncDataSetCompleted(_ dataSet: ArrayDataSet<DocumentoModel, DocumentoMeta>) {
        popular(dataSet)
    }
    
    fileprivate func asyncEnviarCompleted(_ dataSet: ArrayDataSet<DocumentoModel, DocumentoMeta>) {
        popular(dataSet)
        let content = TextUtils.localized(forKey: "Message.ProcessoEnviadoSucesso")
        showMessage(content: content, theme: .success)
    }
    
    fileprivate func asyncReenviarCompleted(_ dataSet: ArrayDataSet<DocumentoModel, DocumentoMeta>) {
        popular(dataSet)
        let content = TextUtils.localized(forKey: "Message.ProcessoReenviadoSucesso")
        showMessage(content: content, theme: .success)
    }
}

// MARK: Asynchronous Methods
extension DocumentoListaViewController {
    
    fileprivate func startAsyncDataSet(_ id: Int) {
        self.showActivityIndicator()
        let observable = DocumentoService.Async.dataSet(id: id)
        prepare(for: observable).subscribe(
            onNext: { dataSet in
                self.asyncDataSetCompleted(dataSet)
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
        let observable = DocumentoService.Async.enviar(id: id)
        prepare(for: observable).subscribe(
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
        let observable = DocumentoService.Async.reenviar(id: id)
        prepare(for: observable).subscribe(
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
    
    fileprivate func startAsyncCriar(_ id: Int, _ uploads: [UploadModel]) {
        self.showActivityIndicator()
        let referencia = "\(id)"
        let observable = DigitalizacaoService.Async.criar(referencia: referencia, tipo: .tipificacao, uploads: uploads)
        prepare(for: observable).subscribe(
            onNext: { model in
                self.asyncCriarCompleted(model)
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
}
