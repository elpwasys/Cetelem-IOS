//
//  PesquisaViewController.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 09/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit

class PesquisaViewController: DrawerViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pagingToolbar: UIToolbar!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var statusButton: UIBarButtonItem!
    @IBOutlet weak var previousButton: UIBarButtonItem!
    
    fileprivate var statusLabel = UILabel()
    
    fileprivate var rows = [ProcessoModel]()
    fileprivate var pesquisaModel: PesquisaModel!
    
    fileprivate var processoMeta: ProcessoMeta?
    fileprivate var processoPagingModel: ProcessoPagingModel?
    
    fileprivate var isMeta: Bool {
        return processoMeta != nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pesquisaModel = PesquisaModel()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        preparePagingToolbar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isMeta {
            startAsyncFiltrar()
        } else {
            startAsyncDataSet()
        }
    }
    
    @IBAction func onSearchTapped(_ sender: UIBarButtonItem) {
        openFiltroDialog()
    }
    
    @IBAction func onRefreshTapped(_ sender: UIBarButtonItem) {
        self.startAsyncFiltrar()
    }
    
    @IBAction func onNextTapped(_ sender: UIBarButtonItem) {
        pesquisaModel.page = pesquisaModel.page + 1
        startAsyncFiltrar()
    }
    
    @IBAction func onPreviousTapped(_ sender: UIBarButtonItem) {
        pesquisaModel.page = pesquisaModel.page - 1
        startAsyncFiltrar()
    }
}

// MARK: PesquisaViewController
extension PesquisaViewController {
    
    fileprivate func preparePagingToolbar() {
        ShadowUtils.applyTop(pagingToolbar)
        statusLabel.sizeToFit()
        statusLabel.font = statusLabel.font.withSize(14.0)
        statusLabel.textAlignment = .center
        statusLabel.textColor = UIColor.white
        statusButton.customView = statusLabel
    }
    
    fileprivate func atualizar(_ model: ProcessoPagingModel) {
        
        self.processoPagingModel = model
        
        if model.hasNext() {
            nextButton.isEnabled = true
        } else {
            nextButton.isEnabled = false
        }
        if model.hasPrevious() {
            previousButton.isEnabled = true
        } else {
            previousButton.isEnabled = false
        }
        
        if model.qtde > 0 {
            statusLabel.text = "\(model.page + 1) / \(model.qtde)"
        } else {
            statusLabel.text = TextUtils.localized(forKey: "Message.SemRegistrosExibir")
        }
        
        statusLabel.sizeToFit()
        
        if let records = self.processoPagingModel?.records {
            rows = records
        } else {
            rows = []
        }
        self.tableView.reloadData()
    }
    
    fileprivate func openFiltroDialog() {
        let dialog = FiltroDialog.create(filtro: pesquisaModel.filtro, meta: processoMeta, view: revealViewController().view)
        dialog.completionHandler = { filtro in
            dialog.hide()
            self.pesquisaModel.filtro = filtro
            self.startAsyncFiltrar()
        }
        dialog.show()
    }
    
    @IBAction func unwindRefresh(segue: UIStoryboardSegue) {
        startAsyncFiltrar()
    }
}


// MARK: UITableViewDelegate
extension PesquisaViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = rows[indexPath.row]
        let controller = UIStoryboard.viewController("Menu", identifier: "Scene.Processo.Detalhe") as! ProcessoDetalheViewController
        controller.id = model.id!
        controller.isLeftMenu = false
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: UITableViewDataSource
extension PesquisaViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProcessoTableViewCell", for: indexPath) as! ProcessoTableViewCell
        let model = rows[indexPath.row]
        cell.populate(model)
        return cell
    }
}

// MARK: Asynchronous Methods
extension PesquisaViewController {
    
    fileprivate func startAsyncFiltrar() {
        showActivityIndicator()
        let observable = PesquisaService.Async.filtrar(model: self.pesquisaModel)
        prepare(for: observable)
            .subscribe(
                onNext: { model in
                    self.asyncFilrarCompleted(model)
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
    
    fileprivate func startAsyncDataSet() {
        showActivityIndicator()
        let observable = PesquisaService.Async.dataSet()
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
                }
            ).addDisposableTo(disposableBag)
    }
}

// MARK: Asynchronous Completed Methods
extension PesquisaViewController {
    
    fileprivate func asyncFilrarCompleted(_ model: ProcessoPagingModel) {
        self.atualizar(model)
    }
    
    fileprivate func asyncDataSetCompleted(_ dataSet: DataSet<ProcessoPagingModel, ProcessoMeta>) {
        self.atualizar(dataSet.data!)
        self.processoMeta = dataSet.meta
    }
}
