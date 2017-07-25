//
//  NovoViewController.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 09/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit
import MaterialComponents

class NovoViewController: DrawerViewController {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var salvarButton: UIButton!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var tipoProcessoPickerField: PickerField!
    
    fileprivate var paths = [String]()
    fileprivate var grupos = [CampoGrupoModel]()
    fileprivate var tipoDataSet: DataSet<TipoProcessoModel, TipoProcessoMeta>?
    
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
        cameraButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if tipoProcessoPickerField.numberOfRows < 1 {
            startAsyncDataSet()
        }
    }
    
    @IBAction func onSalvarPressed() {
        salvar()
    }
    
    @IBAction func onCameraClick(_ sender: UIBarButtonItem) {
        presentSnapViewController()
    }
}

// MARK: Custom
extension NovoViewController {
    
    fileprivate func preapare() {
        prepareTopView()
        prepareTableView()
        prepareSalvarButton()
        prepareTipoProcessoField()
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
    
    fileprivate func prepareSalvarButton() {
        
    }
    
    fileprivate func prepareTipoProcessoField() {
        tipoProcessoPickerField.delegate = self
        tipoProcessoPickerField.labelNormalColor = Color.grey500
        tipoProcessoPickerField.labelActiveColor = Color.primary
        tipoProcessoPickerField.dividerNormalColor = Color.grey500
        tipoProcessoPickerField.dividerActiveColor = Color.primary
    }
    
    fileprivate func presentSnapViewController() {
        let url = ImageService.Directory.temporario.url
        let controller = SnapViewController.create(url: url, paths: paths, with: self)
        self.present(controller, animated: true, completion: nil)
    }
    
    fileprivate func presentDocumentViewController() {
        var models = [TipoDocumentoModel]()
        let dialogTransitionController = MDCDialogTransitionController()
        if let documentos = tipoDataSet?.meta?.tiposDocumentos {
            models = documentos
        }
        let controller = UIStoryboard.viewController("Menu", identifier: "Scene.Dialog.Documento") as! DocumentoDialogViewController
        controller.models = models
        controller.delegate = self
        controller.modalPresentationStyle = .custom
        controller.transitioningDelegate = dialogTransitionController
        present(controller, animated: true, completion: nil)
    }
    
    fileprivate func salvar() {
        if isValid {
            let processo = ProcessoModel()
            processo.gruposCampos = values
            processo.tipoProcesso = tipoProcessoPickerField.value as! TipoProcessoModel
            if paths.isEmpty {
                presentDocumentViewController()
            } else {
                var uploads = [UploadModel]()
                for path in paths {
                    uploads.append(UploadModel(path))
                }
                processo.uploads = uploads
                startAsyncSalvar(processo)
            }
        } else {
            let message = App.Message()
            message.theme = .warning
            message.presentationStyle = .bottom
            message.content = TextUtils.localized(forKey: "Message.FormularioInvalido")
            message.show(self)
        }
    }
}

// MARK: SnapDelegate
extension NovoViewController: SnapDelegate {
    
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

// MARK: PickerFieldDelegate
extension NovoViewController: PickerFieldDelegate {
    
    func pickerField(_ pickerField: PickerField, selected: Selectable?) {
        self.salvarButton.isHidden = true
        self.cameraButton.isEnabled = false
        if let option = selected, let id = Int(option.value) {
            startAsyncTipoDataSet(id: id)
        } else {
            self.grupos.removeAll()
            self.tableView.reloadData()
        }
    }
}

// MARK: DocumentoDialogDelegate
extension NovoViewController: DocumentoDialogDelegate {
    
    func didFecharTapped(_ controller: DocumentoDialogViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func didCapturarTapped(_ controller: DocumentoDialogViewController) {
        controller.dismiss(animated: true) {
            self.presentSnapViewController()
        }
    }
}

// MARK: UITableViewDelegate
extension NovoViewController: UITableViewDelegate {
    
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
extension NovoViewController: UITableViewDataSource {
    
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
        return cell
    }
}

// MARK: Asynchronous Completed Methods
extension NovoViewController {
    
    fileprivate func asyncSalvarCompleted(_ model: ProcessoModel) {
        
    }
    
    fileprivate func asyncDataSetCompleted(_ dataSet: DataSet<ProcessoModel, ProcessoMeta>) {
        if let meta = dataSet.meta {
            tipoProcessoPickerField.entries(array: meta.tiposProcessos)
        }
    }
    
    fileprivate func asyncTipoDataSetCompleted(_ dataSet: DataSet<TipoProcessoModel, TipoProcessoMeta>) {
        self.tipoDataSet = dataSet
        self.grupos = dataSet.meta?.gruposCampos ?? [CampoGrupoModel]()
        self.tableView.reloadData()
        self.salvarButton.isHidden = self.grupos.isEmpty
        self.cameraButton.isEnabled = !self.grupos.isEmpty
    }
}

// MARK: Asynchronous Methods
extension NovoViewController {
    
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
                    self.tipoProcessoPickerField.show()
                }
            ).addDisposableTo(disposableBag)
    }
    
    fileprivate func startAsyncDataSet() {
        self.showActivityIndicator()
        let observable = ProcessoService.Async.dataSet()
        prepare(for: observable)
            .subscribe(
                onNext: { dataSet in
                    self.asyncDataSetCompleted(dataSet)
                },
                onError: { error in
                    self.hideActivityIndicator()
                    self.handle(error)
                },
                onCompleted: {
                    self.hideActivityIndicator()
                    self.tipoProcessoPickerField.show()
                }
            ).addDisposableTo(disposableBag)
    }
    
    fileprivate func startAsyncTipoDataSet(id: Int) {
        showActivityIndicator()
        let observable = ProcessoService.Async.tipoDataSet(id: id)
        prepare(for: observable)
            .subscribe(
                onNext: { dataSet in
                    self.tipoProcessoPickerField.hide()
                    self.asyncTipoDataSetCompleted(dataSet)
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
