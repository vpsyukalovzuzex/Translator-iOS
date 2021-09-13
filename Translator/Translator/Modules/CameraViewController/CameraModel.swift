//
// CameraModel.swift
//

import UIKit
import Core
import RealmSwift
import AVFoundation

class CameraModel: NSObject {
    
    weak var viewController: CameraViewController?
    
    var fromLanguage: Language {
        get {
            // var result = settings.languageFrom!
            // if result.isAuto {
            //     result = TJLanguageService.getRecentlyLanguages(for: .parseImage).first as! TJLanguageRealm
            // }
            // return result
            try! Realm().objects(Language.self).filter { $0.fullCode == "ru_RU" }.first!
        }
        set { /*TJSettingsService.setLanguageFrom(newValue)*/ }
    }
    
    var toLanguage: Language {
        get { /*settings.languageTo*/ try! Realm().objects(Language.self).filter { $0.fullCode == "en_US" }.first! }
        set { /*TJSettingsService.setLanguageTo(newValue)*/ }
    }
    
    // private var settings: TJTranslateSettings { TJSettingsService.defaultSettings() }
    
    private var original:   String?
    private var translated: String?
    
    private var translation: Translation?
    
    private var name: String?
    
    private var words: [String]?
    
    private var originalImage: UIImage?
    
    // private var speechEngine: SpeechEngine { SpeechEngine.sharedInstance() }
    
    private var audioPlayerBlock: ((Bool) -> Void)?
    
    private var audioPlayer: AVAudioPlayer?
    
    private var result: (string: String?, language: Language) {
        let standart = (translated, toLanguage)
        guard let viewController = viewController else {
            return standart
        }
        if viewController.isRecognition {
            guard let words = words, !words.isEmpty else {
                return (name, /*TJLanguageService.defaultLanguage()*/ try! Realm().objects(Language.self).filter { $0.fullCode == "en_US" }.first! )
            }
            let indexPath = viewController.selectedIndexPath
            let row = indexPath == nil ? 0 : indexPath!.row
            if row < words.count {
                return (words[row], toLanguage)
            }
        }
        return standart
    }
    
    // MARK: - Init
    
    init(viewController: CameraViewController) {
        super.init()
        self.viewController = viewController
        self.setup()
    }
    
    // MARK: - Public func
    
    public func appear() {
        // if settings.isFirstPhotoRecognition.boolValue {
        //     viewController?.showInfo()
        //     TJSettingsService.setIsFirstPhotoRecognition(false)
        // }
    }
    
    public func disappear() {
        guard let viewController = viewController else {
            return
        }
        viewController.delegate?.cameraViewController(viewController, didFinishWith: translation)
    }
    
    public func translate() {
        /*
        guard let viewController = viewController else {
            return
        }
        if originalImage == nil {
            originalImage = viewController.image
        }
        guard let originalImage = originalImage else {
            return
        }
        var result = originalImage
        /*
        if let deviceOrientation = viewController.capturedDeviceOrientation {
            switch deviceOrientation {
            case .landscapeLeft:
                result = result.rotated(by:  0.5 * .pi)
            case .landscapeRight:
                result = result.rotated(by: -0.5 * .pi)
            default:
                break
            }
        }
         */
        viewController.showLoader()
        if viewController.isRecognition {
            TJVisionService().processVisionImage(result) { _, _ in
                viewController.hideLoader()
                // Empty.
            } translated: { [weak self] name, array in
                guard let self = self else {
                    return
                }
                let words = array as? [String]
                self.name = name
                self.words = words
                viewController.hideLoader()
                viewController.stringA = name
                viewController.words = words
            } failure: { error in
                viewController.hideLoader()
                viewController.error = error
            }
        } else {
            let size = viewController.cameraSize
            let save = viewController.dropImage == nil
            TJPhotoService().translatePhoto(result, with: size, saveToHistory: save, normalized: nil, success: { [weak self] image, original, translated, translation in
                guard let self = self else {
                    return
                }
                viewController.hideLoader()
                viewController.state = .image(image, false)
                self.original    = original
                self.translated  = translated
                self.translation = translation
            }, failure: { error in
                viewController.hideLoader()
                viewController.error = error
            })
        }
         */
    }
    
    public func showLanguagesViewControllerForA() {
        showLanguagesViewController(/*.from*/ 0)
    }
    
    public func showLanguagesViewControllerForB() {
        showLanguagesViewController(/*.to*/ 0)
    }
    
    public func switchLanguages() {
        let fromLanguage = self.fromLanguage
        let toLanguage = self.toLanguage
        self.fromLanguage = toLanguage
        self.toLanguage = fromLanguage
        updateLanguages()
        translate()
    }
    
    public func copyTranslation() {
        guard let string = result.string else {
            return
        }
        UIPasteboard.general.string = string
    }
    
    public func shareTranslation() {
        guard
            let viewController = viewController,
            let string = result.string,
            let shareButton = viewController.shareButton,
            let view = viewController.view
        else {
            return
        }
        viewController.showActivity(
            with: string,
            sourceView: view,
            sourceRect: shareButton.convert(shareButton.bounds, to: view)
        )
    }
    
    public func playTranslation(_ block: @escaping (Bool) -> Void) {
        let result = self.result
        play(result.string, language: result.language, block)
    }
    
    public func retake() {
        name          = nil
        words         = nil
        original      = nil
        translated    = nil
        translation   = nil
        originalImage = nil
    }
    
    // MARK: - Private func
    
    private func setup() {
        updateLanguages()
    }
    
    private func updateLanguages() {
        guard let viewController = viewController else {
            return
        }
        viewController.titleLanguageA = fromLanguage.title
        viewController.titleLanguageB = toLanguage.title
        // UIImage.loadFlag(by: fromLanguage.imageFile ?? "") { [weak self] image in
        //     guard let self = self else { return }
        //     self.viewController?.imageLanguageA = image ?? self.fromLanguage.image
        // }
        // UIImage.loadFlag(by: toLanguage.imageFile ?? "") { [weak self] image in
        //     guard let self = self else { return }
        //     self.viewController?.imageLanguageB = image ?? self.toLanguage.image
        // }
    }
    
    private func showLanguagesViewController(_ direction: /*LanguageDirection*/ Int) {
        // guard
        //     let viewController = viewController,
        //     let languageViewController = TJLangSelectController.getLanguageViewcontroller()
        // else {
        //     return
        // }
        // languageViewController.delegate = self
        // languageViewController.languageMode = .parseImage
        // languageViewController.selectedIndex = Int(direction.rawValue)
        // languageViewController.selectedLanguage = direction == .to ? toLanguage : fromLanguage
        // viewController.present(languageViewController.navigationController!, animated: true, completion: nil)
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
        //     return
        //      */
        // }
        // /*
        // if language.canPlayServer() {
        //     viewController?.showLoader()
        //     TJRequestManager.instance()?.speechObject(
        //         forText: string,
        //         language: language.localeIdentifier,
        //         gender: "",
        //         rate: "",
        //         pitch: "",
        //         andSucces: { [weak self] data in
        //             guard let self = self else {
        //                 return
        //             }
        //             self.viewController?.hideLoader()
        //             guard
        //                 let data = data,
        //                 let audioPlayer = try? AVAudioPlayer(data: data)
        //             else {
        //                 return
        //             }
        //             block(true)
        //             self.audioPlayerBlock = block
        //             self.audioPlayer = audioPlayer
        //             audioPlayer.enableRate = true
        //             audioPlayer.rate = language.speed?.floatValue ?? 1.0
        //             audioPlayer.delegate = self
        //             audioPlayer.prepareToPlay()
        //             audioPlayer.play()
        //         },
        //         failure: { [weak self] error in
        //             self?.viewController?.hideLoader()
        //             block(false)
        //         }
        //     )
        //     return
        // }
        // block(false)
        //  */
    }
}

extension CameraModel: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        audioPlayerBlock?(false)
        audioPlayerBlock = nil
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        audioPlayerBlock?(false)
        audioPlayerBlock = nil
    }
}

// extension CameraModel: LangSelectDelegate {
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

extension UIImage {
    
    func rotated(by radians: CGFloat) -> UIImage {
        
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(.init(rotationAngle: radians))
            .integral
            .size
        
        UIGraphicsBeginImageContext(rotatedSize)
        
        if let context = UIGraphicsGetCurrentContext() {
            
            let origin = CGPoint(
                x: 0.5 * rotatedSize.width,
                y: 0.5 * rotatedSize.height
            )
            
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            
            draw(
                in: .init(
                    x: -origin.y,
                    y: -origin.x,
                    width: size.width,
                    height: size.height
                )
            )
            
            let rotated = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            return rotated ?? self
            
        }
        
        return self
    }
}
