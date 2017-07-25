//
//  App.swift
//
//  Created by Everton Luiz Pascke on 06/11/16.
//  Copyright © 2016 Everton Luiz Pascke. All rights reserved.
//

import Foundation
import SwiftMessages
import SystemConfiguration

class App {
    static let locale = Locale(identifier: "pt_BR")
    class Message {
        var theme = Theme.info
        var layout: MessageView.Layout?
        var title: String?
        var content: String!
        var dimMode: SwiftMessages.DimMode?
        var duration: SwiftMessages.Duration?
        var presentationStyle: SwiftMessages.PresentationStyle?
        var presentationContext: SwiftMessages.PresentationContext?
        func show(_ sender: Any) {
            let view: MessageView
            if let layout = self.layout {
                switch layout {
                case .TabView:
                    view = MessageView.viewFromNib(layout: .TabView)
                case .CardView:
                    view = MessageView.viewFromNib(layout: .CardView)
                case .StatusLine:
                    view = MessageView.viewFromNib(layout: .StatusLine)
                default:
                    view = try! SwiftMessages.viewFromNib()
                }
            } else {
                view = try! SwiftMessages.viewFromNib()
            }
            view.configureContent(
                title: title,
                body: content,
                iconImage: nil,
                iconText: nil,
                buttonImage: nil,
                buttonTitle: nil,
                buttonTapHandler: { _ in
                    SwiftMessages.hide()
                }
            )
            switch theme {
            case .info:
                view.configureTheme(.info)
            case .error:
                view.configureTheme(.error)
            case .success:
                view.configureTheme(.success)
            case .warning:
                view.configureTheme(.warning)
            /*default:
                view.configureTheme(backgroundColor: UIColor.black, foregroundColor: UIColor.white)
            */
            }
            view.configureDropShadow()
            view.button?.isHidden = true
            view.iconLabel?.isHidden = true
            view.iconImageView?.isHidden = true
            view.bodyLabel?.textAlignment = .center
            if self.title == nil {
                view.titleLabel?.isHidden = true
            }
            var config = SwiftMessages.defaultConfig
            if let dimMode = self.dimMode {
                config.dimMode = dimMode
            }
            if let duration = self.duration {
                config.duration = duration
            }
            if let presentationStyle = self.presentationStyle {
                config.presentationStyle = presentationStyle
            }
            if let presentationContext = self.presentationContext {
                config.presentationContext = presentationContext
            }
            if case .top = config.presentationStyle {
                switch theme {
                case .error, .success, .warning:
                    config.preferredStatusBarStyle = .lightContent
                default:
                    break
                }
            }
            SwiftMessages.show(config: config, view: view)
        }
    }
}

extension UIView {
    func borderTopWith(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    }
    
    func borderRightWith(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: self.frame.size.width - width, y: 0, width: width, height: self.frame.size.height)
        self.layer.addSublayer(border)
    }
    
    func borderBottomWith(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    }
    
    func borderLeftWith(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.size.height)
        self.layer.addSublayer(border)
    }
}

extension UIStoryboard {
    class func viewController(_ name: String, identifier: String) -> UIViewController {
        return UIStoryboard(name: name, bundle: nil).instantiateViewController(withIdentifier: identifier)
    }
}

extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return substring(from: fromIndex)
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return substring(to: toIndex)
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return substring(with: startIndex..<endIndex)
    }
}

extension UIColor {
    
    convenience init(hex: String) {
        
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff,
            alpha: 1
        )
    }
}

extension App {
    class Loading {
        var overlay = UIView()
        var activityIndicator = UIActivityIndicatorView()
        class var shared: Loading {
            struct Static {
                static let instance: Loading = Loading()
            }
            return Static.instance
        }
        public func show(view: UIView) {
            if !activityIndicator.isAnimating {
                // Overlay
                overlay.frame = view.frame
                overlay.center = view.center
                overlay.alpha = 0.5
                overlay.backgroundColor = UIColor.black
                overlay.clipsToBounds = true
                
                // Indicator
                activityIndicator.activityIndicatorViewStyle = .white
                activityIndicator.hidesWhenStopped = true
                activityIndicator.center = overlay.center
                
                overlay.addSubview(activityIndicator)
                view.addSubview(overlay)
                
                activityIndicator.startAnimating()
            }
        }
        
        public func hide() {
            activityIndicator.stopAnimating()
            overlay.removeFromSuperview()
        }
    }
}

class Reachability {
    static func isNetworkAvailable() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
}

class Device {
    
    static var so: String {
        return "IOS"
    }
    
    static var uuid: String {
        return UIDevice.current.identifierForVendor!.uuidString
    }
    
    static var model: String {
        return UIDevice.current.model
    }
    
    static var width: CGFloat {
        return UIScreen.main.bounds.size.width
    }
    
    static var height: CGFloat {
        return UIScreen.main.bounds.size.height
    }
    
    static var systemVersion: String {
        return UIDevice.current.systemVersion
    }
    
    static var appVersion: String? {
        guard let dictionary = Bundle.main.infoDictionary, let version = dictionary["CFBundleVersion"] as? String else {
            return nil
        }
        return version
    }
    
    static var isNetworkAvailable: Bool {
        return Reachability.isNetworkAvailable()
    }
}
