//
//  MenuViewController.swift
//  ClubeMesa
//
//  Created by Everton Luiz Pascke on 10/06/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit

class Menu {
    var id: Int
    var icon: UIImage
    var label: String
    init(id: Int, icon: UIImage, label: String) {
        self.id = id
        self.icon = icon
        self.label = label
    }
}

class MenuViewController: CetelemViewController {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var nomeLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    fileprivate var menus = [Int: [Menu]]()
    fileprivate var headers = [String]()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepare()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension MenuViewController {
    
    fileprivate func prepare() {
        ShadowUtils.applyBottom(topView)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        prepareMenu()
        prepareHeader()
    }
    
    fileprivate func prepareMenu() {
        var value: [Menu]
        // PROCESSO
        headers.append(TextUtils.localized(forKey: "Menu.Processo"))
        value = [
            Menu(id: 1, icon: Icon.add!, label: TextUtils.localized(forKey: "Menu.Novo")),
            Menu(id: 2, icon: Icon.search!, label: TextUtils.localized(forKey: "Menu.Pesquisar"))
        ]
        menus[0] = value
        // APLICATIVO
        headers.append(TextUtils.localized(forKey: "Menu.Aplicativo"))
        value = [
            Menu(id: 3, icon: Icon.powerSettingsNew!, label: TextUtils.localized(forKey: "Menu.Sair"))
        ]
        menus[1] = value
    }
    
    fileprivate func prepareHeader() {
        if let usuario = Usuario.current {
            ViewUtils.text(usuario.nome, for: nomeLabel)
            ViewUtils.text(usuario.email, for: emailLabel)
        }
    }
    
    fileprivate func sair() {
        Dispositivo.current = nil
        let controller = UIStoryboard.viewController("Main", identifier: "Scene.Start")
        self.present(controller, animated: true, completion: nil)
    }
    
    fileprivate func onSairPressed() {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: TextUtils.localized(forKey: "Label.Sair"),
                message: TextUtils.localized(forKey: "Message.SairAplicativo"),
                preferredStyle: UIAlertControllerStyle.actionSheet
            )
            alert.addAction(UIAlertAction(
                title: TextUtils.localized(forKey: "Label.Sim"),
                style: UIAlertActionStyle.default,
                handler: { (action: UIAlertAction!) in
                    self.sair()
            }
            ))
            alert.addAction(UIAlertAction(
                title: TextUtils.localized(forKey: "Label.Nao"),
                style: UIAlertActionStyle.cancel,
                handler: nil
            ))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    fileprivate func close(completion: @escaping () -> Void) {
        let when = DispatchTime.now() + 0.3
        DispatchQueue.main.asyncAfter(deadline: when) {
            completion()
        }
    }
    
    fileprivate func onNovoPressed() {
        let controller = UIStoryboard.viewController("Menu", identifier: "Nav.Novo")
        revealViewController().pushFrontViewController(controller, animated: true)
    }
    
    fileprivate func onPesquisarPressed() {
        let controller = UIStoryboard.viewController("Menu", identifier: "Nav.Pesquisa")
        revealViewController().pushFrontViewController(controller, animated: true)
    }
}

extension MenuViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let menu = menus[indexPath.section]?[indexPath.row] {
            let id = menu.id
            switch id {
            case 1:
                self.onNovoPressed()
                break;
            case 2:
                self.onPesquisarPressed()
                break;
            case 3:
                self.onSairPressed()
                break
            default:
                break
            }
        }
    }
}

extension MenuViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return headers.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus[section]!.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headers[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell", for: indexPath) as! MenuTableViewCell
        let menu = menus[indexPath.section]![indexPath.row]
        cell.populate(menu)
        return cell
    }
}
