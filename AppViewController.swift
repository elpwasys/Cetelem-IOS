//
//  AppViewController.swift
//
//  Created by Everton Luiz Pascke on 28/10/16.
//  Copyright © 2016 Everton Luiz Pascke. All rights reserved.
//

import UIKit
import RxSwift
import SwiftMessages
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
    
    func showMessage(
        content: String,
        theme: Theme = .info,
        dimMode: SwiftMessages.DimMode = .gray(interactive: true),
        duration: SwiftMessages.Duration = .forever,
        presentationStyle: SwiftMessages.PresentationStyle = .bottom) {
        let message = App.Message()
        message.theme = theme
        message.dimMode = dimMode
        message.duration = duration
        message.presentationStyle = presentationStyle
        message.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
        message.content = content
        message.show()
    }
    
    func handle(_ error: Error) {
        let message = App.Message()
        message.theme = .error
        message.dimMode = .gray(interactive: true)
        if error is Trouble {
            let trouble = error as! Trouble
            message.content = trouble.description
            switch trouble {
            case .any(_ ):
                message.duration = .forever
                message.presentationStyle = .bottom
                message.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
            case .server(_ , _):
                message.duration = .forever
                message.presentationStyle = .bottom
                message.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
            case .internetNotAvailable(_):
                message.layout = .StatusLine
                message.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
            }
        } else {
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
        App.Loading.shared.show(view: self.view)
    }
    
    func hideActivityIndicator() {
        App.Loading.shared.hide()
    }
}
