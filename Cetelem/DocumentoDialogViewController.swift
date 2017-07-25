//
//  DocumentoDialogViewController.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 24/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit

protocol DocumentoDialogDelegate {
    
    func didFecharTapped(_ controller: DocumentoDialogViewController)
    func didCapturarTapped(_ controller: DocumentoDialogViewController)
}

class DocumentoDialogViewController: UIViewController {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var fecharButton: UIButton!
    
    var models: [TipoDocumentoModel]?
    var delegate: DocumentoDialogDelegate?
    
    fileprivate var opcionais = [TipoDocumentoModel]()
    fileprivate var obrigatorios = [TipoDocumentoModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepare()
    }

    @IBAction func onFecharTapped() {
        if let delegate = self.delegate {
            delegate.didFecharTapped(self)
        }
    }
    
    @IBAction func onCapturarTapped() {
        if let delegate = self.delegate {
            delegate.didCapturarTapped(self)
        }
    }
}

// MARK: Custom
extension DocumentoDialogViewController {
        
    fileprivate func prepare() {
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: TableHeaderView.nibName, bundle: nil), forHeaderFooterViewReuseIdentifier: TableHeaderView.reusableCellIdentifier)
        ShadowUtils.applyBottom(topView)
        ShadowUtils.applyTop(bottomView)
        //topView.borderBottomWith(color: Color.grey500, width: 1)
        //bottomView.borderTopWith(color: Color.grey500, width: 1)
        if let models = self.models {
            for model in models {
                if !model.isObrigatorio {
                    opcionais.append(model)
                } else {
                    obrigatorios.append(model)
                }
            }
        }
        tableView.reloadData()
    }
}

// MARK: UITableViewDelegate
extension DocumentoDialogViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? TableHeaderView {
            header.contentView.backgroundColor = UIColor.white
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return TableHeaderView.height
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
extension DocumentoDialogViewController: UITableViewDataSource {
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentoTableViewCell", for: indexPath) as! DocumentoTableViewCell
        let documento: TipoDocumentoModel
        if indexPath.section == 0 {
            documento = obrigatorios[indexPath.row]
        } else {
            documento = opcionais[indexPath.row]
        }
        cell.prepare(documento)
        return cell
    }
}
