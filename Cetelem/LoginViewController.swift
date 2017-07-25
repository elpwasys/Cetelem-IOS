//
//  LoginViewController.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 21/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit
import MaterialComponents

class LoginViewController: CetelemViewController {

    @IBOutlet weak var entrarButton: MDCRaisedButton!
    @IBOutlet weak var loginTextField: MaterialTextField!
    @IBOutlet weak var senhaTextField: MaterialTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepare()
    }
    
    @IBAction func onEntrarPressed() {
        entrar()
    }
}

extension LoginViewController {
    
    fileprivate func prepare() {
        prepareEntrarButton()
        prepareLoginTextField()
        prepareSenhaTextField()
    }
    
    fileprivate func prepareEntrarButton() {
        entrarButton.backgroundColor = Color.primary
        entrarButton.customTitleColor = Color.white
    }
    
    fileprivate func prepareLoginTextField() {
        loginTextField.leftImage = Icon.person
        loginTextField.labelNormalColor = Color.grey500
        loginTextField.labelActiveColor = Color.primary
        loginTextField.dividerNormalColor = Color.grey500
        loginTextField.dividerActiveColor = Color.primary
    }
    
    fileprivate func prepareSenhaTextField() {
        senhaTextField.leftImage = Icon.lock
        senhaTextField.labelNormalColor = Color.grey500
        senhaTextField.labelActiveColor = Color.primary
        senhaTextField.dividerNormalColor = Color.grey500
        senhaTextField.dividerActiveColor = Color.primary
    }
    
    fileprivate func entrar() {
        if validate() {
            let login = loginTextField.text!
            let senha = senhaTextField.text!
            startAsyncAutenticar(login: login, senha: senha)
        }
    }
    
    fileprivate func validate() -> Bool {
        var valid = true;
        let requiredText = TextUtils.localized(forKey: "Label.CampoObrigatorio")
        loginTextField.error = nil
        if TextUtils.isBlank(loginTextField.text) {
            let label = TextUtils.localized(forKey: "Label.Login")
            loginTextField.error = "\(label) \(requiredText)"
            valid = false
        }
        senhaTextField.error = nil
        if TextUtils.isBlank(senhaTextField.text) {
            let label = TextUtils.localized(forKey: "Label.Senha")
            senhaTextField.error = "\(label) \(requiredText)"
            valid = false
        }
        return valid
    }
    
    // MARK: COMPLETED ASYNC METHODS
    fileprivate func asyncAutenticarCompleted(dispositivo: Dispositivo) {
        Dispositivo.current = dispositivo
        let controller = UIStoryboard.viewController("Menu", identifier: "Scene.Reveal")
        self.present(controller, animated: true, completion: nil)
    }
    
    // MARK: ASYNC METHODS
    fileprivate func startAsyncAutenticar(login: String, senha: String) {
        showActivityIndicator()
        let observable = DispositivoService.Async.autenticar(login: login, senha: senha)
        prepare(for: observable)
            .subscribe(
                onNext: { dispositivo in
                    self.asyncAutenticarCompleted(dispositivo: dispositivo)
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
