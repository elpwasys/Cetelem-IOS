//
//  AppViewController.swift
//
//  Created by Everton Luiz Pascke on 28/10/16.
//  Copyright © 2016 Everton Luiz Pascke. All rights reserved.
//

import UIKit
import RxSwift
import MaterialComponents

class AppViewController: UIViewController {
    
    let disposableBag = DisposeBag()
    
    var activityIndicator: MDCActivityIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func prepare<T>(for observable: Observable<T>) -> Observable<T> {
        return observable
            .observeOn(MainScheduler.instance)
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
    
    func handle(_ error: Error) {
        let message = App.Message()
        message.theme = .error
        if error is Trouble {
            let trouble = error as! Trouble
            message.content = trouble.description
            switch trouble {
            case .any(_ ):
                message.dimMode = .gray(interactive: true)
                message.duration = .forever
                message.presentationStyle = .bottom
                message.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
            case .server(_ , _):
                message.dimMode = .gray(interactive: true)
                message.duration = .forever
                message.presentationStyle = .bottom
                message.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
            case .internetNotAvailable(_):
                message.layout = .StatusLine
                message.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
            }
        } else {
            message.dimMode = .gray(interactive: true)
            message.duration = .forever
            message.presentationStyle = .bottom
            message.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
            if let error = error as? URLError {
                switch error.code {
                case .cancelled:
                    return
                case .cannotConnectToHost:
                    message.content = TextUtils.localized(forKey: "Message.ServidorIndisponivel")
                case .notConnectedToInternet:
                    let message = TextUtils.localized(forKey: "Message.InternetIndisponivel")
                    handle(Trouble.internetNotAvailable(message))
                    return
                default:
                    message.content = error.localizedDescription
                }
            } else {
                message.content = error.localizedDescription
            }
        }
        message.show(self)
    }
    
    func showActivityIndicator() {
        var view: UIView?
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            view = delegate.window?.subviews.first
        }
        if view == nil {
            view = self.view
        }
        App.Loading.shared.show(view: view!)
    }
    
    func hideActivityIndicator() {
        App.Loading.shared.hide()
    }
}
