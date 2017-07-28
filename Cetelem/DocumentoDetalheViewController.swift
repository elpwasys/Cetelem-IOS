//
//  DocumentoDetalheViewController.swift
//  Cetelem
//
//  Created by Everton Luiz Pascke on 27/07/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit
import Kingfisher
import IRLDocumentScanner

class DocumentoDetalheViewController: CetelemViewController {

    @IBOutlet weak var nomeLabel: UILabel!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var versaoLabel: UILabel!
    @IBOutlet weak var observacaoLabel: UILabel!
    @IBOutlet weak var irregularidadeLabel: UILabel!
    
    @IBOutlet weak var statusImage: UIImageView!
    
    @IBOutlet weak var pendenciaView: UIView!
    @IBOutlet weak var observacaoView: UIView!
    @IBOutlet weak var pendenciaViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var cameraButton: Button!
    @IBOutlet weak var salvarButton: UIButton!
    @IBOutlet weak var excluirButton: UIButton!
    
    var id: Int?
    
    fileprivate var imagens = [ImagemModel]()
    fileprivate var documento: DocumentoModel?
    fileprivate var digitalizacao: DigitalizacaoModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clear()
        prepare()
        carregar()
    }
    
    @IBAction func onInfoTapped() {
        verificarDigitalizacao()
    }
    
    @IBAction func onCameraTapped() {
        openScannerViewController()
    }
    
    @IBAction func onSalvarTapped() {
        salvar()
    }
    
    @IBAction func onExcluirTapped() {
        excluir()
    }
    
    @IBAction func onJustificarTapped() {
        if let documento = self.documento {
            let view = revealViewController().view!
            let dialog = PendenciaDialog.create(model: documento, view: view)
            dialog.completionHandler = { aswner, text in
                dialog.hide()
                if aswner, let justificativa = text {
                    self.justificar(documento.id!, justificativa)
                }
            }
            dialog.show()
        }
    }
}

// MARK: Commons
extension DocumentoDetalheViewController {
    
    static var pendenciaHeight: CGFloat {
        return 78
    }
    
    var hasUpload: Bool {
        for imagem in imagens {
            if TextUtils.isNotBlank(imagem.path) {
                return true
            }
        }
        return false
    }
    
    var isSalvarEnabled: Bool {
        if let documento = self.documento {
            return hasUpload && documento.digitalizavel
        }
        return false
    }
    
    var isCameraEnabled: Bool {
        if let documento = self.documento {
            return documento.digitalizavel
        }
        return false
    }
    
    var isExcluirEnabled: Bool {
        return !imagens.isEmpty
    }
    
    fileprivate func prepare() {
        scrollView.delegate = self
    }
    
    fileprivate func clear() {
        imagens.removeAll()
        configure()
        cameraButton.isHidden = true
        salvarButton.isHidden = true
        excluirButton.isHidden = true
        pendenciaView.isHidden = true
        pendenciaViewHeightConstraint.constant = 0
    }
    
    fileprivate func carregar() {
        if let id = self.id {
            startAsyncObter(id)
        }
    }
    
    fileprivate func salvar() {
        if isSalvarEnabled, let id = self.id {
            var uploads = [UploadModel]()
            for imagem in imagens {
                if TextUtils.isNotBlank(imagem.path) {
                    let path = imagem.path!
                    let upload = UploadModel(path)
                    uploads.append(upload)
                }
            }
            if !uploads.isEmpty {
                startAsyncDigitalizar(id: id, uploads: uploads)
            }
        }
    }
    
    fileprivate func excluir() {
        let index = pageControl.currentPage
        let imagem = imagens[index]
        if TextUtils.isNotBlank(imagem.path) {
            imagens.remove(at: index)
            configure()
            setActionsVisibiliy()
        } else {
            let dialog = Alert.create(view: revealViewController().view)
            dialog.title = TextUtils.localized(forKey: "Label.Excluir")
            dialog.message = TextUtils.localized(forKey: "Message.ExcluirImagem")
            dialog.completionHandler = { answer in
                dialog.hide()
                if answer, let id = imagem.id {
                    self.startAsyncExcluir(id, index)
                }
            }
            dialog.show()
        }
    }
    
    fileprivate func didImageChange(_ imagem: ImagemModel) {
        if TextUtils.isNotBlank(imagem.path) {
            excluirButton.isHidden = false
        } else if let documento = self.documento {
            excluirButton.isHidden = !documento.podeExcluir
        }
    }
    
    fileprivate func openScannerViewController() {
        if isCameraEnabled {
            let scanner = IRLScannerViewController.cameraView(withDefaultType: .normal, defaultDetectorType: .accuracy, with: self)
            scanner.showControls = true
            scanner.detectionOverlayColor = Color.primary
            scanner.showAutoFocusWhiteRectangle = true
            self.present(scanner, animated: true, completion: nil)
        }
    }
    
    fileprivate func setActionsVisibiliy() {
        cameraButton.isHidden = !isCameraEnabled
        salvarButton.isHidden = !isSalvarEnabled
        excluirButton.isHidden = !isExcluirEnabled
    }
    
    fileprivate func justificar(_ id: Int, _ justificativa: String) {
        let model = JustificativaModel(id, justificativa)
        startAsyncJustificar(model)
    }
    
    fileprivate func popular() {
        clear()
        if let documento = self.documento {
            ViewUtils.text(documento.nome, for: nomeLabel)
            ViewUtils.text(documento.versaoAtual, for: versaoLabel)
            ViewUtils.text(documento.status.label, for: statusLabel)
            ViewUtils.text(documento.dataDigitalizacao, for: dataLabel)
            ViewUtils.text(documento.irregularidadeNome, for: irregularidadeLabel)
            ViewUtils.text(documento.pendenciaObservacao, for: observacaoLabel)
            statusImage.image = documento.status.icon
            if documento.status != .pendente {
                pendenciaView.isHidden = true
                pendenciaViewHeightConstraint.constant = 0
            } else {
                pendenciaView.isHidden = false
                pendenciaViewHeightConstraint.constant = DocumentoTableViewCell.pendenciaHeight
            }
            if let imagens = documento.imagens {
                self.imagens = imagens
            }
        }
        configure()
        setActionsVisibiliy()
    }
    
    fileprivate func configure() {
        for view in scrollView.subviews {
            view.removeFromSuperview()
        }
        scrollView.contentSize = CGSize(width: (centerView.frame.width * CGFloat(imagens.count)), height: centerView.frame.height)
        scrollView.isPagingEnabled = true
        for (i, imagem) in imagens.enumerated() {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.isUserInteractionEnabled = true
            imageView.frame = CGRect(x: centerView.frame.width * CGFloat(i), y: 0, width: centerView.frame.width, height: centerView.frame.height)
            scrollView.addSubview(imageView)
            if let path = imagem.path {
                imageView.image = UIImage(contentsOfFile: path)
            } else if imagem.caminho != nil {
                if let url = URL(string: "\(Config.baseURL)\(imagem.caminho!)") {
                    let loading = App.Loading()
                    loading.show(view: imageView)
                    imageView.kf.setImage(with: url) { _, _, _, _ in
                        loading.hide()
                    }
                }
            }
        }
        pageControl.numberOfPages = imagens.count
        pageControl.currentPage = 0
    }
    
    fileprivate func create(image: UIImage) {
        if let data = UIImageJPEGRepresentation(image, 0.8) {
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd_HHmmss'.jpg'"
            let url = ImageService.Directory.temporario.url
            let name = formatter.string(from: date)
            let fileURL = url.appendingPathComponent(name)
            do {
                try data.write(to: fileURL)
            } catch {
                print(error.localizedDescription)
                return
            }
            let model = ImagemModel()
            model.path = fileURL.path
            imagens.append(model)
            configure()
            setActionsVisibiliy()
        }
    }
    
    fileprivate func digitalizar() {
        if let id = self.id {
            startAsyncDigitalizar(id)
        }
    }
    
    fileprivate func verificarDigitalizacao() {
        if let id = self.id {
            startAsyncVerificarDigitalizacao(id)
        }
    }
}

// MARK: UIScrollViewDelegate
extension DocumentoDetalheViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let index = Int(round(scrollView.contentOffset.x / centerView.frame.width))
        pageControl.currentPage = index
        if !imagens.isEmpty {
            let imagem = imagens[index]
            didImageChange(imagem)
        }
    }
}

// MARK: IRLScannerViewControllerDelegate
extension DocumentoDetalheViewController: IRLScannerViewControllerDelegate {
    
    func didCancel(_ cameraView: IRLScannerViewController) {
        cameraView.dismiss(animated: true) {
        }
    }
    
    func pageSnapped(_ image: UIImage, from cameraView: IRLScannerViewController) {
        cameraView.dismiss(animated: true) {
            self.create(image: image)
        }
    }
}


// MARK: Asynchronous Completed Methods
extension DocumentoDetalheViewController {
    
    fileprivate func asyncObterCompleted(_ model: DocumentoModel) {
        self.documento = model
        popular()
    }
    
    fileprivate func asyncExcluirCompleted(_ model: ResultModel, _ index: Int) {
        if model.isSuccess {
            imagens.remove(at: index)
            configure()
            setActionsVisibiliy()
        }
    }
    
    fileprivate func asyncJustificarCompleted(_ model: ResultModel) {
        if model.isSuccess {
            let content = TextUtils.localized(forKey: "Message.JustificativaSucesso")
            showMessage(content: content, theme: .success)
            carregar()
        }
    }
    
    fileprivate func asyncDigitalizarCompleted(_ model: DigitalizacaoModel) {
        do {
            try DigitalizacaoService.digitalizar(tipo: .documento, referencia: model.referencia)
            self.navigationController?.popViewController(animated: true)
            let message = App.Message()
            message.layout = .StatusLine
            message.foregroundColor = Color.white
            message.backgroundColor = Color.accent
            message.duration = .seconds(seconds: 1)
            message.content = TextUtils.localized(forKey: "Message.ImagemUpload")
            message.show()
        } catch {
            handle(error)
        }
    }
    
    fileprivate func asyncVerificarDigitalizacaoCompleted(_ model: DigitalizacaoModel?) {
        digitalizacao = model
        if let digitalizacao = self.digitalizacao {
            let dialog = DigitalizacaoDialog.create(model: digitalizacao, view: revealViewController().view)
            dialog.completionHandler = { answer in
                dialog.hide()
                if answer {
                    self.digitalizar()
                }
            }
            dialog.show()
        } else {
            let message = App.Message()
            message.layout = .StatusLine
            message.backgroundColor = Color.black
            message.foregroundColor = Color.white
            message.duration = .seconds(seconds: 1)
            message.content = TextUtils.localized(forKey: "Message.SemInfoDigitalizacao")
            message.show()
        }
    }
    
    fileprivate func asyncDigitalizarCompleted() {
        self.navigationController?.popViewController(animated: true)
        let message = App.Message()
        message.layout = .StatusLine
        message.foregroundColor = Color.white
        message.backgroundColor = Color.accent
        message.duration = .seconds(seconds: 1)
        message.content = TextUtils.localized(forKey: "Message.ImagemUpload")
        message.show()
    }
}

// MARK: Asynchronous Methods
extension DocumentoDetalheViewController {
    
    fileprivate func startAsyncObter(_ id: Int) {
        self.showActivityIndicator()
        let observable = DocumentoService.Async.obter(id: id)
        prepare(for: observable).subscribe(
            onNext: { model in
                self.asyncObterCompleted(model)
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
    
    fileprivate func startAsyncExcluir(_ id: Int, _ index: Int) {
        self.showActivityIndicator()
        let observable = ImageService.Async.excluir(id: id)
        prepare(for: observable).subscribe(
            onNext: { model in
                self.asyncExcluirCompleted(model, index)
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
    
    fileprivate func startAsyncJustificar(_ model: JustificativaModel) {
        self.showActivityIndicator()
        let observable = DocumentoService.Async.justificar(model: model)
        prepare(for: observable).subscribe(
            onNext: { model in
                self.asyncJustificarCompleted(model)
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
    
    fileprivate func startAsyncDigitalizar(_ id: Int) {
        let referencia = "\(id)"
        let observable = DigitalizacaoService.Async.digitalizar(tipo: .documento, referencia: referencia)
        prepare(for: observable).subscribe(
            onNext: {
                self.asyncDigitalizarCompleted()
            },
            onError: { error in
                self.handle(error)
            }
        ).addDisposableTo(disposableBag)
    }
    
    fileprivate func startAsyncDigitalizar(id: Int, uploads: [UploadModel]) {
        self.showActivityIndicator()
        let referencia = "\(id)"
        let observable = DigitalizacaoService.Async.criar(referencia: referencia, tipo: .documento, uploads: uploads)
        prepare(for: observable).subscribe(
            onNext: { model in
                self.asyncDigitalizarCompleted(model)
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
    
    fileprivate func startAsyncVerificarDigitalizacao(_ id: Int) {
        let referencia = "\(id)"
        let observable = DigitalizacaoService.Async.getBy(referencia: referencia, tipo: .documento)
        prepare(for: observable).subscribe(
            onNext: { model in
                self.asyncVerificarDigitalizacaoCompleted(model)
            },
            onError: { error in
                self.handle(error)
            }
        ).addDisposableTo(disposableBag)
    }
}
