//
//  SnapViewController.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 17/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit
import IRLDocumentScanner

protocol SnapDelegate {
    func didSnapOk(_ paths: [String], from controller: SnapViewController)
    func didSnapCancel(_ paths: [String], from controller: SnapViewController)
}

class SnapViewController: UIViewController {
    
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var trashButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    
    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    fileprivate var url: URL!
    
    fileprivate var paths = [String]()
    fileprivate var oldPaths = [String]()
    fileprivate var isOpenAutomatically = true
    
    var delegate: SnapDelegate?
    
    static func create(url: URL, paths: [String] = [String](), with delegate: SnapDelegate) -> SnapViewController {
        let controller = SnapViewController()
        controller.url = url
        controller.paths = Array(paths)
        controller.oldPaths = Array(paths)
        controller.delegate = delegate
        controller.isOpenAutomatically = paths.isEmpty
        return controller
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        setHiddenCameraButton(isOpenAutomatically)
        configure()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isOpenAutomatically {
            openScanner(false)
            isOpenAutomatically = false
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onOkTapped() {
        if let delegate = self.delegate {
            for path in oldPaths {
                if (!self.paths.contains(path)) {
                    self.remove(path)
                }
            }
            delegate.didSnapOk(self.paths, from: self)
        }
    }
    
    @IBAction func onTrashTapped() {
        let index = pageControl.currentPage
        let path = paths[index]
        if !oldPaths.contains(path) {
            remove(path)
        }
        paths.remove(at: index)
        configure()
    }
    
    @IBAction func onCloseTapped() {
        if let delegate = self.delegate {
            delegate.didSnapCancel(self.oldPaths, from: self)
        }
    }
    
    @IBAction func onCameraTapped() {
        openScanner(true)
    }
}

extension SnapViewController {
    
    fileprivate func setHiddenCameraButton(_ hidden: Bool) {
        if hidden {
            cameraButton.isHidden = true
        } else {
            cameraButton.alpha = 0
            cameraButton.isHidden = false
            let timing = UICubicTimingParameters(animationCurve: .easeIn)
            let animator = UIViewPropertyAnimator(duration: 0.25, timingParameters: timing)
            animator.addAnimations {
                self.cameraButton.alpha = 1
            }
            animator.startAnimation()
        }
    }
    
    fileprivate func remove(_ path: String) {
        do {
            try FileManager.default.removeItem(atPath: path)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    fileprivate func configure() {
        for view in scrollView.subviews {
            view.removeFromSuperview()
        }
        scrollView.contentSize = CGSize(width: (centerView.frame.width * CGFloat(paths.count)), height: centerView.frame.height)
        scrollView.isPagingEnabled = true
        for (i, path) in paths.enumerated() {
            let image = UIImage(contentsOfFile: path)
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.isUserInteractionEnabled = true
            imageView.frame = CGRect(x: centerView.frame.width * CGFloat(i), y: 0, width: centerView.frame.width, height: centerView.frame.height)
            //let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onGestureRecognizer(gestureRecognizer:)))
            //imageView.addGestureRecognizer(gestureRecognizer)
            scrollView.addSubview(imageView)
        }
        pageControl.numberOfPages = paths.count
        pageControl.currentPage = 0
        trashButton.isHidden = paths.isEmpty
        okButton.isHidden = paths.isEmpty && oldPaths.isEmpty
    }
    
    func onGestureRecognizer(gestureRecognizer: UITapGestureRecognizer) {
        let view = gestureRecognizer.view
        if view is UIImageView {
            //let controller = ImageViewController()
            //self.present(controller, animated: true, completion: nil)
        }
    }
    
    fileprivate func openScanner(_ animated: Bool) {
        setHiddenCameraButton(true)
        //let scanner = IRLScannerViewController.standardCameraView(with: self)
        let scanner = IRLScannerViewController.cameraView(withDefaultType: .normal, defaultDetectorType: .accuracy, with: self)
        scanner.showControls = true
        scanner.detectionOverlayColor = Color.primary
        scanner.showAutoFocusWhiteRectangle = true
        self.present(scanner, animated: animated, completion: nil)
    }
    
    fileprivate func create(image: UIImage) {
        if let data = UIImageJPEGRepresentation(image, 0.8) {
            let manager = FileManager.default
            if !manager.fileExists(atPath: self.url.path) {
                do {
                    try manager.createDirectory(at: self.url, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print(error.localizedDescription)
                    return
                }
            }
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd_HHmmss'.jpg'"
            let name = formatter.string(from: date)
            let fileURL = self.url.appendingPathComponent(name)
            do {
                try data.write(to: fileURL)
            } catch {
                print(error.localizedDescription)
                return
            }
            paths.append(fileURL.path)
            self.configure()
            self.openScanner(false)
        }
    }
}

extension SnapViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let index = round(scrollView.contentOffset.x / centerView.frame.width)
        pageControl.currentPage = Int(index)
    }
}

extension SnapViewController: IRLScannerViewControllerDelegate {
    
    func didCancel(_ cameraView: IRLScannerViewController) {
        if self.paths.isEmpty {
            self.closeButton.isHidden = true
            cameraView.dismiss(animated: false) {
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            cameraView.dismiss(animated: true) {
                self.setHiddenCameraButton(false)
            }
        }
    }
    
    func pageSnapped(_ image: UIImage, from cameraView: IRLScannerViewController) {
        cameraView.dismiss(animated: true) {
            self.setHiddenCameraButton(false)
            self.create(image: image)
        }
    }
}
