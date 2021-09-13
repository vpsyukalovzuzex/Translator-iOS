//
// CameraViewController.swift
//

import UIKit
import Core
import CameraManager

protocol CameraViewControllerDelegate: AnyObject {
    
    func cameraViewController(_ cameraViewController: CameraViewController, didFinishWith translation: Translation?)
}

class CameraViewController: UIViewController {
    
    // MARK: - Internal enum
    
    internal enum State {
        
        case camera
        case image(UIImage, Bool)
    }
    
    internal enum Mode {
        
        case translation
        case recognition
    }
    
    // MARK: - @IBOutlet
    
    @IBOutlet weak var cameraView: UIView!
    
    @IBOutlet weak var languageButtonA: LanguageButton!
    @IBOutlet weak var languageButtonB: LanguageButton!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var shutterView: UIView!
    
    @IBOutlet weak var closeButton:  UIButton!
    @IBOutlet weak var albumButton:  UIButton!
    @IBOutlet weak var copyButton:   UIButton!
    @IBOutlet weak var takeButton:   UIButton!
    @IBOutlet weak var retakeButton: UIButton!
    @IBOutlet weak var flashButton:  UIButton!
    @IBOutlet weak var shareButton:  UIButton!
    @IBOutlet weak var visionButton: UIButton!
    @IBOutlet weak var playButton:   UIButton!
    
    @IBOutlet weak var recognitionView: UIView!
    @IBOutlet weak var errorView:       UIView!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var stringALabel:     UILabel!
    @IBOutlet weak var stringBLabel:     UILabel!
    @IBOutlet weak var errorLabel:       UILabel!
    
    @IBOutlet weak var stringABStackView: UIStackView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Private let
    
    private let cameraManager = CameraManager()
    
    // MARK: - Public var
    
    @objc public var dropImage: UIImage?
    
    public var titleLanguageA: String? {
        get { languageButtonA.title }
        set { languageButtonA.title = newValue }
    }
    
    public var titleLanguageB: String? {
        get { languageButtonB.title }
        set { languageButtonB.title = newValue }
    }
    
    public var imageLanguageA: UIImage? {
        get { languageButtonA.image }
        set { languageButtonA.image = newValue }
    }
    
    public var imageLanguageB: UIImage? {
        get { languageButtonB.image }
        set { languageButtonB.image = newValue }
    }
    
    public var image: UIImage? {
        get { imageView.image }
        set {
            imageView.image = newValue
            imageView.isHidden = newValue == nil
        }
    }
    
    public var isRecognition: Bool { mode == .recognition }
    
    public var stringA: String? {
        get { stringALabel.text }
        set {
            stringALabel.text = newValue
            stringALabel.isHidden = newValue == nil
        }
    }
    
    public var stringB: String? {
        get { stringBLabel.text }
        set {
            stringBLabel.text = newValue
            stringBLabel.isHidden = newValue == nil
        }
    }
    
    public var words: [String]? {
        didSet {
            let isHidden = words == nil
            descriptionLabel.isHidden  = !isHidden
            stringABStackView.isHidden =  isHidden
            collectionView.isHidden    =  isHidden
            selectedIndexPath = nil
            collectionView.reloadData()
        }
    }
    
    public var error: Error? {
        didSet {
            errorLabel.text = error?.localizedDescription
            errorView.setIsHidden(error == nil)
        }
    }
    
    public var cameraSize: CGSize { cameraView.bounds.size }
    
    public var state: State = .camera {
        didSet {
            switch state {
            case .camera:
                albumButton.isHidden  = false
                copyButton.isHidden   = true
                takeButton.isHidden   = false
                retakeButton.isHidden = true
                flashButton.isHidden  = false
                shareButton.isHidden  = true
                visionButton.isHidden = false
                playButton.isHidden   = true
                self.image = nil
            case .image(let image, let shouldTranslate):
                albumButton.isHidden  = true
                copyButton.isHidden   = false
                takeButton.isHidden   = true
                retakeButton.isHidden = false
                flashButton.isHidden  = true
                shareButton.isHidden  = false
                visionButton.isHidden = true
                playButton.isHidden   = false
                self.image = image
                if shouldTranslate {
                    cameraModel.translate()
                }
            }
        }
    }
    
    public var mode: Mode = .translation {
        didSet {
            visionButton.isSelected = isRecognition
            recognitionView.setIsHidden(!isRecognition)
        }
    }
    
    public var shareButtonRect: CGRect { shareButton.bounds }
    
    public weak var delegate: CameraViewControllerDelegate?
    
    public var selectedIndexPath: IndexPath?
    
    public private(set) var capturedDeviceOrientation: UIDeviceOrientation?
    
    // MARK: - Private var
    
    private var cameraModel: CameraModel!
    
    private var manager = OrientationManager()
    
    private var deviceOrientation: UIDeviceOrientation = .unknown {
        didSet {
            var transform: CGAffineTransform
            switch deviceOrientation {
            case .portrait:
                transform = .identity
            case .landscapeLeft:
                transform = .init(rotationAngle:  0.5 * .pi)
            case .landscapeRight:
                transform = .init(rotationAngle: -0.5 * .pi)
            default:
                return
            }
            setTransform(transform)
        }
    }
        
    // MARK: - Public override func
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // AppDelegate.lock(.portrait, rotateTo: .portrait)
        manager.delegate = self
        manager.start()
        cameraModel = CameraModel(viewController: self)
        cameraManager.addPreviewLayerToView(cameraView)
        cameraManager.cameraOutputQuality = .hd1280x720
        cameraManager.animateShutter = false
        cameraManager.writeFilesToPhoneLibrary = false
        cameraManager.shouldRespondToOrientationChanges = false
        cameraManager.shouldKeepViewAtOrientationChanges = false
        flashButton.isEnabled = cameraManager.hasFlash
        languageButtonA.textColor = .white
        languageButtonB.textColor = .white
        languageButtonA.expandColor = .white
        languageButtonB.expandColor = .white
        state   = .camera
        mode    = .translation
        stringA = nil
        stringB = nil
        words   = nil
        error   = nil
        view.addInteraction(UIDropInteraction(delegate: self))
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraManager.resumeCaptureSession()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cameraModel.appear()
        if let dropImage = dropImage {
            state = .image(dropImage, true)
        }
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cameraManager.stopCaptureSession()
        cameraModel.disappear()
        manager.stop()
        // AppDelegate.lock(.allButUpsideDown)
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        DispatchQueue.main.async { [weak self] in
            self?.cameraManager.resetOrientation()
        }
    }
    
    // MARK: - Public func
    
    public func showInfo() {
        /*
        let alertController = UIAlertController(
            title: LSMainLocalize("_loc_photo_translator"),
            message: LSMainLocalize("_loc_photo_instruction"),
            preferredStyle: .alert
        )
        let alertAction = UIAlertAction(
            title: LSMainLocalize("_loc_button_ok"),
            style: .cancel,
            handler: nil
        )
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
         */
    }
    
    // MARK: - Private func
    
    private func setTransform(_ transform: CGAffineTransform, animated: Bool = true) {
        let views: [UIView?] = [
            languageButtonA.imageView,
            languageButtonB.imageView,
            closeButton,
            albumButton,
            copyButton,
            takeButton,
            retakeButton,
            flashButton,
            shareButton,
            visionButton,
            playButton
        ]
        if animated {
            UIView.animate(withDuration: 0.2) {
                for view in views {
                    view?.transform = transform
                }
            }
        } else {
            for view in views {
                view?.transform = transform
            }
        }
    }
    
    private func animateShutter() {
        shutterView.isHidden = false
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveLinear) {
            self.shutterView.alpha = 0.6
        } completion: { _ in
            UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveLinear) {
                self.shutterView.alpha = 0.0
            } completion: { _ in
                self.shutterView.isHidden = true
            }
        }
    }
    
    private func word(by indexPath: IndexPath) -> String? {
        guard let words = words else {
            return nil
        }
        let row = indexPath.row
        if row < words.count {
            return words[row]
        }
        return nil
    }
    
    private func cropImage(with image: UIImage, scaledToFill size: CGSize) -> UIImage {
        let scale: CGFloat = max(size.width / image.size.width, size.height / image.size.height)
        let width: CGFloat = image.size.width * scale
        let height: CGFloat = image.size.height * scale
        let imageRect = CGRect(
            x: 0.5 * (size.width - width),
            y: 0.5 * (size.height - height),
            width: width,
            height: height
        )
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        image.draw(in: imageRect)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result ?? image
    }
    
    // MARK: - @IBAction
    
    @IBAction private func languageButtonATouchUpInsideAction(_ sender: LanguageButton) {
        error = nil
        cameraModel.showLanguagesViewControllerForA()
    }
    
    @IBAction private func languageButtonBTouchUpInsideAction(_ sender: LanguageButton) {
        error = nil
        cameraModel.showLanguagesViewControllerForB()
    }
    
    @IBAction private func switchButtonTouchUpInsideAction(_ sender: UIButton) {
        error = nil
        cameraModel.switchLanguages()
    }
    
    @IBAction func closeButtonAction(_ sender: UIButton) {
        error = nil
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func albumButtonAction(_ sender: UIButton) {
        error = nil
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = false
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func copyButtonAction(_ sender: UIButton) {
        error = nil
        cameraModel.copyTranslation()
    }
    
    @IBAction func takeButtonAction(_ sender: UIButton) {
        error = nil
        animateShutter()
        capturedDeviceOrientation = deviceOrientation
        cameraManager.capturePictureWithCompletion { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let content):
                print("[CameraViewController] \(#function) \(content)")
                if let image = content.asImage {
                    self.state = .image(self.cropImage(with: image, scaledToFill: self.cameraView.frame.size), true)
                }
            case .failure(let error):
                print("[CameraViewController] \(#function) \(error)")
                self.error = error
            }
        }
    }
    
    @IBAction func retakeButtonAction(_ sender: UIButton) {
        error   = nil
        stringA = nil
        stringB = nil
        words   = nil
        state   = .camera
        cameraModel.retake()
    }
    
    @IBAction func flashButtonAction(_ sender: UIButton) {
        error = nil
        if cameraManager.hasFlash {
            sender.isSelected = !sender.isSelected
            cameraManager.flashMode = sender.isSelected ? .on : .off
        }
    }
    
    @IBAction func shareButtonAction(_ sender: UIButton) {
        error = nil
        cameraModel.shareTranslation()
    }
    
    @IBAction func visionButtonAction(_ sender: UIButton) {
        error = nil
        mode = sender.isSelected ? .translation : .recognition
    }
    
    @IBAction func playButton(_ sender: UIButton) {
        error = nil
        cameraModel.playTranslation { isPlaying in
            sender.isSelected = isPlaying
        }
    }
    
    @IBAction func errorViewTap(_ sender: UITapGestureRecognizer) {
        error = nil
    }
}

extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            state = .image(image, true)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

extension CameraViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return words?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = "RecognitionCollectionViewCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! RecognitionCollectionViewCell
        cell.title = word(by: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel()
        label.text = word(by: indexPath)
        label.font = UIFont.systemFont(ofSize: 16.0, weight: .bold)
        label.sizeToFit()
        return CGSize(width: 24.0 + label.frame.width, height: 44.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        stringB = word(by: indexPath)
        selectedIndexPath = indexPath
    }
}

extension CameraViewController: UIDropInteractionDelegate {
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        for item in session.items {
            let provider = item.itemProvider
            if provider.canLoadObject(ofClass: UIImage.self) {
                DispatchQueue.global(qos: .background).async {
                    provider.loadObject(ofClass: UIImage.self) { object, error in
                        if error != nil {
                            return
                        }
                        if let image = object as? UIImage {
                            DispatchQueue.main.async { [weak self] in
                                self?.state = .image(image, true)
                            }
                        }
                    }
                }
            }
        }
    }
}

extension CameraViewController: OrientationManagerDelegate {
    
    func orientationManager(_ orientationManager: OrientationManager, didChange deviceOrientation: UIDeviceOrientation) {
        // self.deviceOrientation = deviceOrientation
    }
}

class RecognitionCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }
}

private extension UIView {
    
    func setIsHidden(_ isHidden: Bool, animated: Bool = true) {
        let alpha: CGFloat = isHidden ? 0.0 : 1.0
        if animated {
            UIView.animate(withDuration: 0.2) {
                self.alpha = alpha
            }
        } else {
            self.alpha = alpha
        }
    }
}
