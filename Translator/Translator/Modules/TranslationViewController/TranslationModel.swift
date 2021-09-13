//
//  TranslationModel.swift
//

import UIKit
import CoreSpotlight
import AVFoundation
import Core
import Common
import RealmSwift

// import MBProgressHUD
// import Adapty

// class TranslationManager: NSObject {
//
//     static let shared = TranslationManager()
//
//     var string: String?
//     var from: String?
//     var to: String?
// }

class TranslationModel: NSObject {
    
    enum LanguageMode {
        
        case a, b
    }
    
    // MARK: - Private static
    
    private static var instance: TranslationModel?
    
    // MARK: - Internal
    
    internal weak var viewController: TranslationViewController?
    
    internal var fromLanguage: Language {
        get { /*settings.languageFrom*/ try! Realm().objects(Language.self).filter { $0.fullCode == "en_US" }.first! }
        set { /*TJSettingsService.setLanguageFrom(newValue)*/ }
    }
    
    internal var toLanguage: Language {
        get { /*settings.languageTo*/ try! Realm().objects(Language.self).filter { $0.fullCode == "ru_RU" }.first! }
        set { /*TJSettingsService.setLanguageTo(newValue)*/ }
    }
    
    // internal var settings: TJTranslateSettings { TJSettingsService.defaultSettings() }
    
    internal var isPaid: Bool { /*TJSettingsService.isPaidVersion()*/ false }
    
    // internal var speechEngine: SpeechEngine { SpeechEngine.sharedInstance() }
    
    internal var original: String? { getOriginal() }
    
    internal var translation: Translation? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.updateTranslation()
            }
        }
    }
    
    internal var shouldUseReturnKey: Bool {
        return /*TJUtils.userSettings()[kUserDefaultReturn] as? Bool ?? false*/ false
    }
    
    // MARK: - Private
    
    // private var translationObserver: TranslationObserver?
    
    private var autocompleteItem: DispatchWorkItem?
    
    private var autocompleteTask: URLSessionDataTask?
    
    private var translateTask: URLSessionDataTask?
    
    private var taskLexicalMeaning: URLSessionDataTask?
    
    private var maxExample: UInt { 5 }
    
    private var date: Date?
    
    private var isSpeech = false
    
    private var audioPlayerBlock: ((Bool) -> Void)?
    
    private var audioPlayer: AVAudioPlayer?
    
    // MARK: - Init
    
    init(viewController: TranslationViewController) {
        super.init()
        self.viewController = viewController
        self.setup()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public static
    
    public static func translate(with string: String) {
        guard let instance = TranslationModel.instance else {
            return
        }
        instance.viewController?.textA = string
        instance.translate()
    }
    
    // public static func translate(with string: String, from: String, to: String) {
    //     let manager = TranslationManager.shared
    //     guard let instance = TranslationModel.instance else {
    //         manager.string = string
    //         manager.from = from
    //         manager.to   = to
    //         return
    //     }
    //     instance.fromLanguage = TJLanguageService.language(forLocaleIdentifier: from)
    //     instance.toLanguage = TJLanguageService.language(forLocaleIdentifier: to)
    //     instance.viewController?.textA = string
    //     instance.translate()
    //     manager.string = nil
    //     manager.from = nil
    //     manager.to = nil
    // }
    
    // public static func setTranslation(_ translation: TJTranslationRealm) {
    //     TranslationModel.instance?.translation = translation
    // }
    
    // public static func setup(with userActivity: NSUserActivity) {
    //     guard let instance = TranslationModel.instance else {
    //         return
    //     }
    //     if let spotlightId = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
    //         guard
    //             let value = Int(spotlightId.replacingOccurrences(of: "translate_", with: "")),
    //             let translation = TJDataManager.sharedInstance().getRealObject(byId: NSNumber(value: value))
    //         else {
    //             return
    //         }
    //         instance.translation = translation
    //     } else {
    //         guard let string = userActivity.userInfo?["com.nordicwise.translator.siri.shortcut"] as? String else {
    //             return
    //         }
    //         switch string {
    //         case "text.translator":
    //             instance.viewController?.focusOnTextViewA()
    //         case "voice.translator":
    //             instance.showVoiceViewController()
    //         case "photo.translator":
    //             instance.showPhotoViewController()
    //         default:
    //             break
    //         }
    //     }
    // }
    
    public static func showVoiceViewController() {
        TranslationModel.instance?.showVoiceViewController()
    }
    
    public static func showPhotoViewController() {
        TranslationModel.instance?.showPhotoViewController()
    }
    
    public static func showWebViewController() {
        TranslationModel.instance?.showWebViewController()
    }
    
    // MARK: - Public
    
    // public func shouldShow() {
    //     let manager = TranslationManager.shared
    //     guard
    //         let string = manager.string,
    //         let from = manager.from,
    //         let to = manager.to
    //     else {
    //         return
    //     }
    //     TranslationModel.translate(with: string, from: from, to: to)
    // }
    
    public func enter(_ word: String?) {
        autocompleteItem?.cancel()
        autocompleteTask?.cancel()
        guard let word = word, !word.isEmpty else {
            viewController?.autocompletes = []
            return
        }
        autocompleteItem = DispatchWorkItem { [weak self] in
            // guard let self = self else {
            //     return
            // }
            // self.autocompleteTask = TJRequestManager.instance().getWordEntries(forText: word, fromLang: self.fromLanguage.localeIdentifier) { autocompletes in
            //     self.viewController?.autocompletes = autocompletes as? [String] ?? []
            // } failure: { _ in
            //     self.viewController?.autocompletes = []
            // }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: autocompleteItem!)
    }
    
    public func showLanguagesViewControllerForA() {
        // Analytics.track(.translation, .clickChoiceLanguageFrom, standart)
        showLanguagesViewController(/*.from*/ 0)
    }
    
    public func showLanguagesViewControllerForB() {
        // Analytics.track(.translation, .clickChoiceLanguageTo, standart)
        showLanguagesViewController(/*.to*/ 0)
    }
    
    public func switchLanguages() {
        // Analytics.track(.translation, .clickReverseLanguage, standart)
        let fromLanguage = self.fromLanguage
        let toLanguage = self.toLanguage
        self.fromLanguage = toLanguage
        self.toLanguage = fromLanguage
        updateLanguages()
        translate()
    }
    
    public func showOfflineDownloadViewController() {
        let index = 3
        guard
            let tabBarController = viewController?.tabBarController,
            let navigationController = tabBarController.viewControllers?[index] as? UINavigationController,
            let viewController = navigationController.viewControllers.first
        else {
            return
        }
        tabBarController.selectedIndex = index
        viewController.performSegue(withIdentifier: "OfflineSegue", sender: self)
    }
    
    public func showVoiceViewController() {
        // Analytics.track(.translation, .clickRecord, standart)
        // PermissionManager.voiceTranslation { [weak self] a, b in
        //     guard let self = self else {
        //         return
        //     }
        //     var result: UIViewController
        //     if a && b {
        //         if !self.isPaid {
        //             let count = self.settings.dayTranslationSpeakCount?.intValue ?? 0
        //             if count >= 3 {
        //                 self.showPurchasesViewController()
        //                 return
        //             }
        //         }
        //         let voiceViewController = SpeechRecognitionVC()
        //         voiceViewController.modalPresentationStyle = .fullScreen
        //         voiceViewController.textChangeDelegate = self
        //         result = voiceViewController
        //     } else {
        //         let permissionViewController = VoiceTranslatePVC()
        //         permissionViewController.onClose = { isGranted in
        //             if isGranted {
        //                 self.showVoiceViewController()
        //             }
        //         }
        //         result = permissionViewController
        //     }
        //     self.viewController?.present(result, animated: true, completion: nil)
        // }
    }
    
    public func showPhotoViewController(with image: UIImage? = nil) {
        // Analytics.track(.translation, .clickTranslatePicture, standart)
        let cameraViewController = CameraViewController.instantiate()
        cameraViewController.modalPresentationStyle = .fullScreen
        viewController?.present(cameraViewController, animated: true, completion: nil)
        if image == nil && !isPaid {
            showPurchasesViewController()
            return
        }
        // if !TJUtils.isNetworkAvailable() {
        //     viewController?.showUnavailableNetworkError()
        //     return
        // }
        // PermissionManager.cameraTranslation { [weak self] a, b in
        //     guard let self = self else {
        //         return
        //     }
        //     var result: UIViewController
        //     if a && b {
        //         let cameraViewController = CameraViewController.create()
        //         cameraViewController.delegate = self
        //         cameraViewController.dropImage = image
        //         cameraViewController.modalPresentationStyle = .fullScreen
        //         result = cameraViewController
        //     } else {
        //         let permissionViewController = CameraPhotoPVC()
        //         permissionViewController.onClose = { isGranted in
        //             if isGranted {
        //                 self.showPhotoViewController(with: image)
        //             }
        //         }
        //         result = permissionViewController
        //     }
        //     self.viewController?.present(result, animated: true, completion: nil)
        // }
    }
    
    public func showWebViewController() {
        // Analytics.track(.translation, .clickTranslateWebSite, languages)
        // if !isPaid {
        //     showPurchasesViewController()
        //     return
        // }
        // if !TJUtils.isNetworkAvailable() {
        //     viewController?.showUnavailableNetworkError()
        //     return
        // }
        // let result = WebTranslationViewController.create()
        // result.modalPresentationStyle = .fullScreen
        // viewController?.present(result, animated: true, completion: nil)
        let webTranslationViewController = WebTranslationViewController.instantiate()
        webTranslationViewController.modalPresentationStyle = .fullScreen
        viewController?.present(webTranslationViewController, animated: true, completion: nil)
    }
    
    public func showDocumentViewController() {
        // Analytics.track(.translation, .clickTranslateFile, standart)
        if !isPaid {
            showPurchasesViewController()
            return
        }
        // if !TJUtils.isNetworkAvailable() {
        //     viewController?.showUnavailableNetworkError()
        //     return
        // }
        let types = [
            "public.image",
            "com.microsoft.word.doc",
            "public.text",
            "com.apple.iwork.pages.pages",
            "public.data",
            "com.adobe.pdf"
        ]
        let documentViewController = UIDocumentPickerViewController.init(documentTypes: types, in: .import)
        documentViewController.modalPresentationStyle = .fullScreen
        documentViewController.delegate = self
        viewController?.present(documentViewController, animated: true, completion: nil)
    }
    
    public func showFullScreenViewController() {
        // Analytics.track(.translation, .clickOpenFullscreen, standart)
        guard
            let viewController = viewController,
            let string = viewController.textB,
            !string.isEmpty
        else {
            return
        }
        // let fullScreenViewController = TJScaleViewController()
        // fullScreenViewController.textForView = string
        // viewController.present(fullScreenViewController, animated: true, completion: nil)
    }
    
    public func showShareViewController() {
        // Analytics.track(.translation, .clickShare, standart)
        guard
            let viewController = viewController,
            let string = viewController.textB,
            !string.isEmpty
        else {
            return
        }
        viewController.showActivity(
            with: string,
            sourceView: viewController.view,
            sourceRect: viewController.shareButtonRect
        )
    }
    
    public func translate() {
        guard let original = original else {
            return
        }
        Core.translate(string: original, fromLanguage: fromLanguage, toLanguage: toLanguage).done { translation in
            self.translation = translation
            self.process()            
        }.catch { error in
            print(error)
        }.finally {
            
        }
        /*
         viewController?.showSpinnerWithCancel(target: self, action: #selector(cancelTranslate))
         */
        // viewController?.customActivityIndicator.startAnimating()
        // translateTask?.cancel()
        // taskLexicalMeaning?.cancel()
        // let date = Date()
        // self.date = date
        // translateTask = TranslationService().translate(with: original, translationSuccess: { [weak self] translation, taskLexicalMeaning in
        //     DispatchQueue.main.async {
        //         guard let self = self else {
        //             return
        //         }
        //         /*
        //          self.viewController?.hideSpinner()
        //          */
        //         self.viewController?.customActivityIndicator.stopAnimating()
        //         self.taskLexicalMeaning = taskLexicalMeaning
        //         self.translation = translation
        //         self.process()
        //         var parameters = self.parametrs(with: .time)
        //         parameters["time"] = -1.0 * date.timeIntervalSinceNow
        //         Analytics.track(.translation, .translateCompleted, parameters)
        //     }
        // }, lexicalMeaningSuccess: { _, _ in
        //     /* Nothing. */
        // }, fail: { [weak self] error in
        //     DispatchQueue.main.async {
        //         guard
        //             let self = self,
        //             let viewController = self.viewController
        //         else {
        //             return
        //         }
        //         /*
        //          viewController.hideSpinner()
        //          */
        //         viewController.customActivityIndicator.stopAnimating()
        //         if (error as NSError).code == TJErrorCode.offlinePackageNotDownloaded.rawValue {
        //             TJUtils.alert(
        //                 withTitle: "_loc_error".localizable,
        //                 message: error.localizedDescription,
        //                 actionButtonTitle: "_loc_download".localizable,
        //                 actionButtonHandler: { _ in
        //                     self.showOfflineDownloadViewController()
        //                 },
        //                 cancelButtonTitle: "_loc_cancel".localizable,
        //                 controller: viewController
        //             )
        //             return
        //         }
        //         TJUtils.errorAlert(withMessage: error.localizedDescription, in: viewController)
        //         var parameters = self.parametrs(with: .time)
        //         parameters["time"] = -1.0 * date.timeIntervalSinceNow
        //         Analytics.track(.translation, .translateFailed, parameters)
        //     }
        // })
    }
    
    public func playTextA() {
        // Analytics.track(.translation, .clickSpeakOriginalText, standart)
        play(viewController?.textA, language: fromLanguage) { [weak self] isPlaying in
            self?.viewController?.isSelectedPlayButtonA = isPlaying
        }
    }
    
    public func playTextB() {
        // Analytics.track(.translation, .clickSpeakTranslatedText, standart)
        play(translation?.result, language: toLanguage) { [weak self] isPlaying in
            self?.viewController?.isSelectedPlayButtonB = isPlaying
        }
    }
    
    public func play(_ string: String?, language: LanguageMode, _ block: @escaping (_ isPlaying: Bool) -> Void) {
        play(string, language: language == .a ? fromLanguage : toLanguage, block)
    }
    
    public func switchFavorite() {
        // Analytics.track(.translation, .clickFavourite, standart)
        guard let translation = translation else {
            return
        }
        // let isFavorite = translation.isFavorite?.boolValue ?? false
        // TJDataManager.sharedInstance().setFavorite(!isFavorite, forObject: translation)
    }
    
    public func showPurchasesViewController() {
        // Analytics.track(.translation, .clickUnlockMoreFunctions, languages)
        // PurchaseScreenPresenter.shared.show()
        let iapViewController = IAPViewController.construct()
        viewController?.present(iapViewController, animated: true, completion: nil)
    }
    
    public func showSignUpOfferViewControllerIfNeeded() {
        // guard
        //     settings.isNeededShowRegistrationOffer,
        //     let value = settings.remoteSettings?.showRegisterOfferInterval.intValue,
        //     let count = settings.dayTranslationPassedCount?.intValue,
        //     value > 0,
        //     count >= value,
        //     count % value == 0
        // else {
        //     return
        // }
        // showSignUpOfferViewController()
    }
    
    public func showSignUpOfferViewController() {
        // Analytics.track(.translation, .showSignUpOffer, languages)
        // let signUpOfferViewController = SignUpOfferViewController.create()
        // signUpOfferViewController.delegate = self
        // viewController?.present(signUpOfferViewController, animated: true, completion: nil)
    }
    
    // MARK: - Private
    
    private func setup() {
        updateMode()
        updateLanguages()
        updateTranslation()
        let center = NotificationCenter.default
        center.addObserver(
            self,
            selector: #selector(validatingInAppNotification(_:)),
            name: NSNotification.Name("kValidatingInAppNotification"),
            object: nil
        )
        center.addObserver(
            self,
            selector: #selector(updateLanguages),
            name: NSNotification.Name(rawValue: "didFetchLanguages"),
            object: nil
        )
        TranslationModel.instance = self
    }
    
    @objc private func updateLanguages() {
        guard let viewController = viewController else {
            return
        }
        let modes = fromLanguage.modes
        viewController.isVoiceEnabled = modes.contains(.speechRecognition)
        let a = modes.contains(.imageRecognition)
        let b = modes.contains(.imageObjectRecognition)
        viewController.isPhotoEnabled = a || b
        viewController.titleLanguageA = fromLanguage.title
        viewController.titleLanguageB = toLanguage.title
        viewController.imageLanguageA = fromLanguage.image
        viewController.imageLanguageB = toLanguage.image
        viewController.isCanPlayA     = false // fromLanguage.canPlay()
        viewController.isCanPlayB     = false // toLanguage.canPlay()
        viewController.isRtlA         = false // fromLanguage.isRTL
        viewController.isRtlB         = false // toLanguage.isRTL
        // UIImage.loadFlag(by: fromLanguage.imageFile ?? "") { [weak self] image in
        //     guard let self = self, let image = image else { return }
        //     self.viewController?.imageLanguageA = image
        // }
        // UIImage.loadFlag(by: toLanguage.imageFile ?? "") { [weak self] image in
        //     guard let self = self, let image = image else { return }
        //     self.viewController?.imageLanguageB = image
        // }
    }
    
    private func updateMode() {
        guard let viewController = viewController else {
            return
        }
        var mode = TranslationViewController.Mode()
        mode.insert(.translation)
        if !isPaid {
            mode.insert(.banner)
        }
        // if let lexicalMeaning = translation?.lexicalMeaning {
        //     var isDictionary = false
        //     if let speechs = lexicalMeaning.storagePartOfSpeech, speechs.count > 0 {
        //         isDictionary = true
        //     }
        //     if let examples = lexicalMeaning.examples, examples.count > 0 {
        //         isDictionary = true
        //     }
        //     if isDictionary {
        //         mode.insert(.dictionary)
        //     }
        // }
        mode.insert(.logo)
        viewController.mode = mode
    }
    
    private func showLanguagesViewController(_ direction: /*LanguageDirection*/ Int) {
        guard let viewController = viewController else {
            return
        }
        // TJLangSelectController.showLanguagesViewController(with: direction, for: viewController, delegate: self)
    }
    
    private func process() {
        guard
            let translation = translation,
            let viewController = viewController
        else {
            return
        }
        // if isSpeech && settings.autoSpeak.boolValue {
        //     isSpeech = false
        //     play(translation.translatedText, language: toLanguage) { viewController.isSelectedPlayButtonB = $0 }
        // }
        // if !isPaid {
        //     let remoteSettings = settings.remoteSettings
        //     if remoteSettings?.crossPromoPopup?.boolValue ?? false {
        //         TJCrossPromoService.crossPromoActionComplition { alertController in
        //             guard let alertController = alertController else {
        //                 return
        //             }
        //             viewController.present(alertController, animated: true, completion: nil)
        //         }
        //     }
        // }
        // ArmchairPresenter.showIfNeeded()
        // PurchaseScreenPresenter.shared.showAfterTranslationIfNeeded()
        showSignUpOfferViewControllerIfNeeded()
        // TJSettingsService.increaseTranslateCount()
    }
    
    private func play(_ string: String?, language: Language, _ block: @escaping (_ isPlaying: Bool) -> Void) {
        // speechEngine.stopRecognize()
        // if speechEngine.speaking || (audioPlayer?.isPlaying ?? false) {
        //     speechEngine.stopSpeaking()
        //     audioPlayer?.stop()
        //     audioPlayer = nil
        //     block(false)
        //     return
        // }
        // guard let string = string else {
        //     block(false)
        //     return
        // }
        // if language.canPlay() {
        //     speechEngine.playText(
        //         toSpeechWithiOS: string,
        //         lang: language.localeIdentifier,
        //         andRate: CGFloat(language.speed?.floatValue ?? 0.5),
        //         andPitch: CGFloat(language.pitch?.floatValue ?? 1.25),
        //         andGender: CGFloat(language.gender?.floatValue ?? 0.0)) { [weak self] isPlaying, error in
        //         block(isPlaying)
        //         if let error = error {
        //             TJUtils.errorAlert(
        //                 withMessage: error.localizedDescription,
        //                 in: self?.viewController
        //             )
        //         }
        //     }
        //     /*
        //      return
        //      */
        // }
        /*
         if language.canPlayServer() {
         viewController?.showLoader()
         TJRequestManager.instance()?.speechObject(
         forText: string,
         language: language.localeIdentifier,
         gender: "",
         rate: "",
         pitch: "",
         andSucces: { [weak self] data in
         guard let self = self else {
         return
         }
         self.viewController?.hideLoader()
         guard
         let data = data,
         let audioPlayer = try? AVAudioPlayer(data: data)
         else {
         return
         }
         block(true)
         self.audioPlayerBlock = block
         self.audioPlayer = audioPlayer
         audioPlayer.enableRate = true
         audioPlayer.rate = language.speed?.floatValue ?? 1.0
         audioPlayer.delegate = self
         audioPlayer.prepareToPlay()
         audioPlayer.play()
         },
         failure: { [weak self] error in
         self?.viewController?.hideLoader()
         block(false)
         }
         )
         return
         }
         block(false)
         */
    }
    
    public func translateDocument(with url: URL) {
        // guard let viewController = viewController else {
        //     return
        // }
        // let component = url.lastPathComponent as NSString
        // let name = component.deletingPathExtension
        // let pathExtension = component.pathExtension
        // let hud = MBProgressHUD.showAdded(to: viewController.view, animated: true)
        // hud.mode = .determinateHorizontalBar
        // hud.label.text = "_loc_translate_translating_file".localizable
        // hud.button.setTitle("_loc_cancel".localizable, for: .normal)
        // hud.button.addTarget(
        //     self,
        //     action: #selector(buttonTouchUpInsideAction(_:)),
        //     for: .touchUpInside
        // )
        // let date = Date()
        // self.date = date
        // TJWebSocketManager.sharedInstance().translateFile(
        //     with: url,
        //     fileName: name,
        //     type: pathExtension,
        //     translateLimit: "5000",
        //     progress: { progress in
        //         DispatchQueue.main.async {
        //             guard
        //                 let progress = progress,
        //                 let value = Float(progress)
        //             else {
        //                 return
        //             }
        //             hud.progress = value / 100.0
        //         }
        //     },
        //     success: { [weak self] string in
        //         DispatchQueue.main.async {
        //             guard
        //                 let self = self,
        //                 let string = string,
        //                 let url = URL(string: string)
        //             else {
        //                 return
        //             }
        //             var parameters = self.languages
        //             parameters["time"] = -1.0 * date.timeIntervalSinceNow
        //             // Analytics.track(.translation, .translateFileCompleted, parameters)
        //             hud.hide(animated: true)
        //             self.showDocument(with: url)
        //         }
        //     },
        //     failure: { [weak self] error in
        //         DispatchQueue.main.async {
        //             guard
        //                 let self = self,
        //                 let viewController = self.viewController,
        //                 let error = error
        //             else {
        //                 return
        //             }
        //             var parameters = self.languages
        //             parameters["error"] = error.localizedDescription
        //             parameters["time"] = -1.0 * date.timeIntervalSinceNow
        //             // Analytics.track(.translation, .translateFileCompleted, parameters)
        //             hud.hide(animated: true)
        //             TJUtils.errorAlert(
        //                 withMessage: error.localizedDescription,
        //                 in: viewController
        //             )
        //         }
        //     }
        // )
    }
    
    private func showDocument(with url: URL) {
        let interactionController = UIDocumentInteractionController(url: url)
        interactionController.delegate = self
        interactionController.presentPreview(animated: true)
    }
    
    private func getOriginal() -> String? {
        if let original = viewController?.textA, !original.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return original
        }
        return nil
    }
    
    // MARK: - didSet
    
    private func updateTranslation() {
        // translationObserver = TranslationObserver(translation: translation, delegate: self)
        // let isCanPlayA = self.settings.languageFrom.canPlay()
        // let isCanPlayB = self.settings.languageTo.canPlay()
        // let settings = TJUtils.userSettings()
        let isTransliteration = /*settings?[kUserDefaultTransliteration] as? Bool ?? false*/ false
        let transliterationA = translation?.sourceTransliteration ?? ""
        let transliterationB = translation?.resultTransliteration ?? ""
        let newline = NSAttributedString(
            string: "\n",
            attributes: main
        )
        if isTransliteration && !transliterationA.isEmpty {
            let textA = NSMutableAttributedString(
                string: translation?.source ?? "",
                attributes: main
            )
            let attributedTransliterationA = NSAttributedString(
                string: transliterationA,
                attributes: transliteration
            )
            textA.append(newline)
            textA.append(attributedTransliterationA)
            viewController?.attributedTextA = textA
        } else {
            viewController?.textA = translation?.source
        }
        if isTransliteration && !transliterationB.isEmpty {
            let textB = NSMutableAttributedString(
                string: translation?.result ?? "",
                attributes: main
            )
            let attributedTransliterationB = NSAttributedString(
                string: transliterationB,
                attributes: transliteration
            )
            textB.append(newline)
            textB.append(attributedTransliterationB)
            viewController?.attributedTextB = textB
        } else {
            viewController?.textB = translation?.result
        }
        // viewController?.isSelectedFavoriteButton = translation?.isFavorite?.boolValue ?? false
        // fromLanguage = translation?.languageFrom ?? fromLanguage
        // toLanguage = translation?.languageTo ?? toLanguage
        // viewController?.word = translation?.lexicalMeaning?.original
        // viewController?.transcription = translation?.lexicalMeaning?.transcription
        var parts = [Any]()
        // if let speechs = translation?.lexicalMeaning?.storagePartOfSpeech, speechs.count > 0 {
        //     for i in 0..<speechs.count {
        //         let speech = speechs.object(at: i)
        //         parts.append(NameInfo(string: speech.name.uppercased()))
        //         if let lexicals = speech.storageLexicalPart {
        //             var number = 1
        //             for i in 0..<lexicals.count {
        //                 let lexical = lexicals.object(at: i)
        //                 if let definition = lexical.definition {
        //                     parts.append(DefinitionInfo(string: "\(number). \(definition)"))
        //                     number += 1
        //                 }
        //                 if let original = translation?.lexicalMeaning?.original {
        //                     if let synonym = lexical.wordsSynonymWithoutOriginal(original) {
        //                         let info = LexicalMeaningInfo(string: "_loc_dictionary_syn".localizable + ":")
        //                         info.words = synonym
        //                         parts.append(info)
        //                     }
        //                     if let hyponym = lexical.wordsHyponymWithoutOriginal(original) {
        //                         let info = LexicalMeaningInfo(string: "_loc_dictionary_hyponym".localizable + ":")
        //                         info.words = hyponym
        //                         parts.append(info)
        //                     }
        //                     if let hypernym = lexical.wordsHypernymWitouthOriginal(original) {
        //                         let info = LexicalMeaningInfo(string: "_loc_dictionary_hypernym".localizable + ":")
        //                         info.words = hypernym
        //                         parts.append(info)
        //                     }
        //                 }
        //                 if let examples = lexical.exemplesOfDefinition as? [String] {
        //                     for example in examples {
        //                         parts.append(LexicalExample(string: example, isCanPlay: isCanPlayA))
        //                     }
        //                 }
        //             }
        //         }
        //     }
        // }
        // if let examples = translation?.lexicalMeaning?.examples, examples.count > 0 {
        //     parts.append(Header(string: "_loc_translation_in_context".localizable))
        //     let count = examples.count < maxExample ? examples.count : maxExample
        //     for i in 0..<count {
        //         let example = examples.object(at: i)
        //         parts.append(FromExample(string: example.fromText, isCanPlay: isCanPlayA))
        //         parts.append(ToExample(string: example.toText, isCanPlay: isCanPlayB))
        //     }
        // }
        viewController?.parts = parts
        updateLanguages()
        updateMode()
    }
    
    // MARK: - @objc
    
    @objc private func validatingInAppNotification(_ notification: Notification) {
        updateMode()
    }
    
    private func buttonTouchUpInsideAction(_ sender: UIButton) {
        var parameters = languages
        if let date = date {
            parameters["time"] = -1.0 * date.timeIntervalSinceNow
            self.date = nil
        }
        // Analytics.track(.translation, .translateFileClose, parameters)
        // TJWebSocketManager.sharedInstance().resetData()
        // if let viewController = viewController {
        //     MBProgressHUD.hide(for: viewController.view, animated: true)
        // }
    }
    
    private func cancelTranslate() {
        translateTask?.cancel()
        taskLexicalMeaning?.cancel()
        var parametrs = self.parametrs(with: .time)
        if let date = date {
            parametrs["time"] = -1.0 * date.timeIntervalSinceNow
            self.date = nil
        }
        // Analytics.track(.translation, .translateCanceled, parametrs)
    }
}

// extension TranslationModel: LangSelectDelegate {
//
//     func itemSelected(_ item: TJLanguageRealm!, direction: LanguageDirection) {
//         guard let item = item else {
//             return
//         }
//         if direction == .from {
//             fromLanguage = item
//         } else {
//             toLanguage = item
//         }
//         updateLanguages()
//         translate()
//     }
// }

// extension TranslationModel: TranslationObserverDelegate {
//
//     func translationDidDelete() {
//         translation = nil
//     }
//
//     func translationDidChange() {
//         DispatchQueue.main.async { [weak self] in
//             self?.updateTranslation()
//         }
//     }
// }

// extension TranslationModel: SpeechRecognitionVCProtocol {
//
//     func speechRecognitedTextChanged(_ text: String?) {
//         guard let text = text else {
//             return
//         }
//         viewController?.textA = text
//     }
//
//     func speechRecognitionFinished(withText text: String?) {
//         guard let text = text else {
//             return
//         }
//         viewController?.textA = text
//         isSpeech = true
//         translate()
//     }
//
//     func requestProVersion() {
//         showPurchasesViewController()
//     }
// }

extension TranslationModel: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            return
        }
        let pathExtension = (url.path as NSString).pathExtension.lowercased()
        if pathExtension.isEmpty {
            return
        }
        switch pathExtension {
        case "jpg", "jpeg", "png":
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async { [weak self] in
                    self?.showPhotoViewController(with: image)
                }
            }
        default:
            let coordinator = NSFileCoordinator(filePresenter: nil)
            coordinator.coordinate(
                readingItemAt: url,
                options: .immediatelyAvailableMetadataOnly,
                error: nil,
                byAccessor: { [weak self] in self?.translateDocument(with: $0) }
            )
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        // Analytics.track(.translation, .translateFileClose, languages)
    }
}

extension TranslationModel: UIDocumentInteractionControllerDelegate {
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return viewController ?? UIViewController()
    }
}

internal extension Language {
    
    var title: String? { /*TJLanguageService.languageTitleWithoutCountry(withLanguage: self)*/ self.englishName }
    
    var image: UIImage? { UIImage(named: (flagPath as NSString).lastPathComponent) }
}

private extension TranslationModel {
    
    var main: [NSAttributedString.Key : Any] {
        return [
            .font : font,
            .foregroundColor : UIColor(named: "r_main_text")!
        ]
    }
    
    var transliteration: [NSAttributedString.Key : Any] {
        return [
            .font : font,
            .foregroundColor : UIColor(named: "r_transliteration_text")!
        ]
    }
    
    private var font: UIFont { UIFont(name: "SFProText-Regular", size: 18.0) ?? .systemFont(ofSize: 18.0, weight: .regular) }
}

extension TranslationModel {
    
    struct Option: OptionSet {
        
        let rawValue: Int
        
        static let original         = Option(rawValue: 1 << 0)
        static let translated       = Option(rawValue: 1 << 1)
        static let languageFrom     = Option(rawValue: 1 << 2)
        static let languageTo       = Option(rawValue: 1 << 3)
        static let originalLenght   = Option(rawValue: 1 << 0)
        static let translatedLenght = Option(rawValue: 1 << 1)
        
        static let standart: Option = [
            .original,
            .translated,
            .languages
        ]
        
        static let languages: Option = [
            .languageFrom,
            .languageTo
        ]
        
        static let time: Option = [
            .standart,
            .languages,
            .originalLenght,
            .translatedLenght
        ]
    }
    
    var standart: [String : Any] {
        return parametrs(with: .standart)
    }
    
    var languages: [String : Any] {
        return parametrs(with: .languages)
    }
    
    func parametrs(with option: Option) -> [String : Any] {
        var result = [String : Any]()
        if option.contains(.original) {
            if let value = viewController?.textA {
                result["original_text"] = value
            }
        }
        if option.contains(.translated) {
            if let value = viewController?.textB {
                result["translated_text"] = value
            }
        }
        if option.contains(.languageFrom) {
            // if let value = fromLanguage.localeIdentifier {
            //     result["language_from"] = value
            // }
        }
        if option.contains(.languageTo) {
            // if let value = toLanguage.localeIdentifier {
            //     result["language_to"] = value
            // }
        }
        if option.contains(.originalLenght) {
            if let value = viewController?.textA?.count {
                result["original_text_length"] = value
            }
        }
        if option.contains(.translatedLenght) {
            if let value = viewController?.textB?.count {
                result["translated_text_length"] = value
            }
        }
        return result
    }
}

// extension TranslationModel: SignUpOfferViewControllerDelegate {
//
//     func signUpOfferViewControllerDidActionRegister(_ viewController: SignUpOfferViewController) {
//         TJTabBarRootController.current()?.showSignUp()
//     }
// }

extension TranslationModel: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        audioPlayerBlock?(false)
        audioPlayerBlock = nil
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        audioPlayerBlock?(false)
        audioPlayerBlock = nil
    }
}

// extension TranslationModel: CameraViewControllerDelegate {
//
//     func cameraViewController(_ cameraViewController: CameraViewController, didFinishWith translation: TJTranslationRealm?) {
//         DispatchQueue.main.async { [weak self] in
//             self?.translation = translation
//         }
//     }
// }
