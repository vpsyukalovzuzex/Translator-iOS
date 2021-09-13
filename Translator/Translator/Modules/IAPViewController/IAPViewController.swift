//
//  IAPViewController.swift
//

import UIKit
import Common
import StoreKit

@objc public protocol IAPCoordinator {
    
    var owner: UIViewController? { get set }
    
    func close()
    
    func didPurchase()
    
    func didRestore()
    
    func didRefresh()
}

@objc public class IAPMainCoordinator: NSObject, IAPCoordinator {
    
    public weak var owner: UIViewController?
    
    public func close() {
        // if Counter.isTriggered(for: "iap_close", 1) {
        //     let viewController = TJPropositionViewController()
        //     viewController.modalPresentationStyle = .fullScreen
        //     owner?.present(viewController, animated: true, completion: nil)
        // } else {
        //     dismiss()
        // }
        dismiss()
    }
    
    public func didPurchase() {
        dismiss()
    }
    
    public func didRestore() {
        dismiss()
    }
    
    public func didRefresh() {}
    
    private func dismiss() {
        if let owner = owner {
            NotificationCenter.default.removeObserver(owner)
        }
        // owner?.hideSpinner()
        owner?.dismiss(animated: true, completion: nil)
    }
}

@objc public class IAPOnboardCoordinator: NSObject, IAPCoordinator {
    
    public weak var owner: UIViewController?
    
    public func close() {
        next()
    }
    
    public func didPurchase() {}
    
    public func didRestore() {
        // owner?.hideSpinner()
    }
    
    public func didRefresh() {
        // if TJSettingsService.isPaidVersion() {
        //     next()
        // }
    }
    
    private func next() {
        if let owner = owner {
            NotificationCenter.default.removeObserver(owner)
        }
        // owner?.hideSpinner()
        var viewController: UIViewController
        // if TJSettingsService.defaultSettings()?.remoteSettings?.showOnboarding?.boolValue ?? true {
        //     viewController = OnboardViewController.create()
        // } else {
        //     /*
        //      viewController = VoiceTranslatePVC()
        //      */
        //     owner?.dismiss(animated: true, completion: nil)
        //     return
        // }
        // owner?.navigationController?.pushViewController(viewController, animated: true)
    }
}

class IAPViewController: UIViewController {
    
    @objc public static func construct() -> IAPViewController {
        let value = 0 // TJSettingsService.defaultSettings()?.remoteSettings?.subscriptionScreenType?.intValue ?? 0
        var viewController: IAPViewController
        switch value {
        case 2:
            viewController = IAPViewControllerAppStore.instantiate()
        case 3:
            viewController = IAPViewControllerTypeA.instantiate()
        case 4:
            viewController = IAPViewControllerTypeB.instantiate()
        default:
            viewController = IAPViewController.instantiate()
        }
        return viewController
    }
    
    @objc public var coordinator: IAPCoordinator? {
        didSet {
            coordinator?.owner = self
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var subtextLabel: UILabel!
    
    @IBOutlet weak var purchaseAButton: UIButton!
    @IBOutlet weak var purchaseBButton: UIButton!
    
    @IBOutlet weak var restorePurchaseButton: UIButton!
    
    @IBOutlet weak var spacer: UIView!
    
    var isTrial: Bool { true }
    
    var stringA: NSString { "com.nordicwise.translator.proversion.year.trial" }
    var stringB: NSString { "com.nordicwise.translator.proversion.month" }
    
    private var manager: PurchaseManagerProtocol { FactoryPurchaseManager.purchaseManager(.swifty) }
    
    var purchaseA: PurchaseProtocol? { manager.purchase(by: stringA) }
    var purchaseB: PurchaseProtocol? { manager.purchase(by: stringB) }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenDidLoad()
        fill()
        register()
        manager.request()
    }
    
    func screenDidLoad() {
        // Analytics.track(.iap)
    }
    
    private func register() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(didPurchase(_:)), name: .didPurchase, object: nil)
        center.addObserver(self, selector: #selector(didRequest(_:)), name: .didRequest, object: nil)
        center.addObserver(self, selector: #selector(didError(_:)), name: .didError, object: nil)
        center.addObserver(self, selector: #selector(didRestore(_:)), name: .didRestore, object: nil)
        center.addObserver(self, selector: #selector(didRefresh(_:)), name: .didRefresh, object: nil)
    }
    
    @IBAction func closeButton(_ sender: UIButton) {
        // Analytics.track(.iap, .clickClosePurchases)
        coordinator?.close()
    }
    
    func titleForButtonA() -> String? {
        return "_loc_try_free_and_subscribe".localizable
    }
    
    func titleForButtonB() -> String? {
        return purchaseB?.price as String?
    }
    
    private func fill() {
        purchaseAButton.setTitle(titleForButtonA(), for: .normal)
        purchaseBButton.setTitle(titleForButtonB(), for: .normal)
        spacer.isHidden = !isTrial
        subtitleLabel.isHidden = !isTrial
        subtextLabel.isHidden = !isTrial
        if isTrial {
            guard let price = purchaseA?.periodPrice else {
                return
            }
            let stringA = "_loc_three_days_trial".localizable
            let stringB = String(format: "_loc_auto_renews_at".localizable, price as String)
            let stringC = "_loc_cancel_any_time".localizable
            let stringABC: NSString = "\(stringA). \(stringB)\n\(stringC)" as NSString
            let result = NSMutableAttributedString(string: stringABC as String, attributes: nil)
            result.addAttributes(
                [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14.0, weight: .regular)],
                range: stringABC.range(of: stringA)
            )
            result.addAttributes(
                [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14.0, weight: .bold)],
                range: stringABC.range(of: stringB)
            )
            result.addAttributes(
                [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14.0, weight: .regular)],
                range: stringABC.range(of: stringC)
            )
            subtextLabel.attributedText = result
        }
    }
    
    func clickPurchaseA() {
        // Analytics.track(.iap, .clickYearTrialPurchase)
    }
    
    func clickPurchaseB() {
        // Analytics.track(.iap, .clickMonthPurchase)
    }
    
    @IBAction func purchaseAButtonAction(_ sender: UIButton) {
        clickPurchaseA()
        // showSpinner()
        purchaseA?.makePurchase()
    }
    
    @IBAction func purchaseBButtonAction(_ sender: UIButton) {
        clickPurchaseB()
        // showSpinner()
        purchaseB?.makePurchase()
    }
    
    @IBAction func restorePurchaseButtonAction(_ sender: UIButton) {
        // showSpinner()
        manager.restore()
        // Analytics.track(.iap, .clickRestorePurchase)
    }
    
    @objc private func didPurchase(_ notification: Notification) {
        coordinator?.didPurchase()
    }
    
    @objc private func didRequest(_ notification: Notification) {
        fill()
    }
    
    @objc private func didError(_ notification: Notification) {
        // hideSpinner()
        if let type = notification.userInfo?["type"] as? Int, type == 1 {
            return
        }
        guard let error = notification.userInfo?["error"] as? NSError else {
            return
        }
        if (error.domain == SKError.errorDomain && error.code == SKError.paymentCancelled.rawValue) {
            // Analytics.track(.iap, .clickCancelPurchase)
            return
        }
        if let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? NSError,
           underlyingError.domain == "ASDServerErrorDomain" && underlyingError.code == 3532 {
            return
        }
        // TJUtils.errorAlert(withMessage: error.localizedDescription, in: self)
    }
    
    @objc private func didRestore(_ notification: Notification) {
        coordinator?.didRestore()
    }
    
    @objc private func didRefresh(_ notification: Notification) {
        coordinator?.didRefresh()
    }
}

class IAPViewControllerAppStore: IAPViewController {
    
    override var isTrial: Bool { false }
    
    override var stringA: NSString { "com.nordicwise.translator.proversion" }
    
    override func titleForButtonA() -> String? {
        return purchaseA?.price as String?
    }
    
    override func screenDidLoad() {
        //
    }
    
    override func clickPurchaseA() {
        //
    }
    
    override func clickPurchaseB() {
        //
    }
}

class IAPViewControllerTypeA: IAPViewController {
    
    override var isTrial: Bool { true }
    
    override var stringA: NSString { "com.nordicwise.translator.proversion.week.trial" }
    
    override func screenDidLoad() {
        // Analytics.track(.iapA)
    }
    
    override func clickPurchaseA() {
        // Analytics.track(.iapA, .clickWeekTrialPurchase)
    }
}

class IAPViewControllerTypeB: IAPViewController {
    
    override var isTrial: Bool { true }
    
    override var stringA: NSString { "com.nordicwise.translator.proversion.year.trial" }
    
    override func screenDidLoad() {
        // Analytics.track(.iapB)
    }
    
    override func clickPurchaseA() {
        // Analytics.track(.iapB, .clickYearTrialPurchase)
    }
}
