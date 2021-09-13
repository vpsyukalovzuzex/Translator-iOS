//
//  SwiftyPurchaseManager.swift
//

import Foundation
import SwiftyStoreKit
import StoreKit

@objc internal class SwiftyPurchaseManager: PurchaseManager {
    
    private var productIds: [NSString] { info.map { $0.identifier } }
    
    private static var sharedSercret: String = ""
    
    // MARK: - Override func
    
    override func setup(parameters: NSDictionary, info: [PurchaseInfo]) {
        super.setup(parameters: parameters, info: info)
        SwiftyPurchaseManager.sharedSercret = parameters["sharedSecret"] as? String ?? ""
        SwiftyStoreKit.completeTransactions { purchases in
            purchases.forEach {
                switch $0.transaction.transactionState {
                case .purchased, .restored:
                    if $0.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction($0.transaction)
                    }
                default:
                    break
                }
            }
        }
    }
    
    override public func request() {
        print("[SwiftyPurchaseManager] Start request;")
//        TJAnalyticsManager.trackEvent(
//            withCategory: "SwiftyPurchaseManager",
//            action: "Start request",
//            params: nil,
//            type: .mamoto,
//            truncValue: 128
//        )
        super.request()
        let finish = {
            print("[SwiftyPurchaseManager] Finish request;")
//            TJAnalyticsManager.trackEvent(
//                withCategory: "SwiftyPurchaseManager",
//                action: "Finish request",
//                params: nil,
//                type: .mamoto,
//                truncValue: 128
//            )
        }
        let productIdentifiers = info.map { $0.identifier as String }
        SwiftyStoreKit.retrieveProductsInfo(Set(productIdentifiers)) { [weak self] results in
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }
                if let error = results.error {
                    let nsError = error as NSError
                    print("[SwiftyPurchaseManager] Retrieve products info error: \(nsError);")
//                    TJAnalyticsManager.trackEvent(
//                        withCategory: "SwiftyPurchaseManager",
//                        action: "Retrieve products info error",
//                        params: nsError.plainUnderlyingErrors(),
//                        type: .mamoto,
//                        truncValue: 128
//                    )
                    self.notificationCenter.post(error)
                    finish()
                    return
                }
                results.retrievedProducts.forEach {
                    print("[SwiftyPurchaseManager] Retrieved product: \($0);")
//                    TJAnalyticsManager.trackEvent(
//                        withCategory: "SwiftyPurchaseManager",
//                        action: "Retrieved product",
//                        params: [
//                            "productIdentifier" : $0.productIdentifier
//                        ],
//                        type: .mamoto,
//                        truncValue: 128
//                    )
                }
                self.purchases = results.retrievedProducts.compactMap { skProduct in
                    if let info = self.purchaseInfo(by: skProduct.productIdentifier) {
                        return SwiftyPurchase(
                            identifier: skProduct.productIdentifier as NSString,
                            price: NSString(format: "%@ - %@", info.localizedPeriod, skProduct.resultPrice),
                            periodPrice: NSString(format: "%@ / %@", skProduct.resultPrice, info.localizedShortPeriod),
                            analog: info.localizedAnalog
                        )
                    }
                    return nil
                }
                self.save()
                self.notificationCenter.post(name: .didRequest, object: nil)
                finish()
            }
        }
    }
    
    override public func refresh() {
        super.refresh()
        SwiftyPurchaseManager.refresh(with: productIds)
    }
    
    override public func refresh(with block: (() -> Void)?) {
        super.refresh(with: block)
        SwiftyPurchaseManager.refresh(with: productIds, block)
    }
    
    override public func restore() {
        print("[SwiftyPurchaseManager] Start restore;")
//        TJAnalyticsManager.trackEvent(
//            withCategory: "SwiftyPurchaseManager",
//            action: "Start restore",
//            params: nil,
//            type: .mamoto,
//            truncValue: 128
//        )
        super.restore()
        SwiftyStoreKit.restorePurchases { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }
                result.restoredPurchases.forEach {
                    print("[SwiftyPurchaseManager] Restored purchase: \($0);")
//                    TJAnalyticsManager.trackEvent(
//                        withCategory: "SwiftyPurchaseManager",
//                        action: "Restored purchase",
//                        params: [
//                            "productId" : $0.productId,
//                            "originalPurchaseDate" : $0.originalPurchaseDate
//                        ],
//                        type: .mamoto,
//                        truncValue: 128
//                    )
                }
                result.restoreFailedPurchases.forEach {
                    print("[SwiftyPurchaseManager] Restore failed purchase: \(String(describing: $0.1)) - \($0.0);")
                    var parameters = [
                        "productId" : $0.1 ?? "nil",
                        "(SKError) errorCode" : "\($0.0.errorCode)",
                        "(SKError) localizedDescription" : $0.0.localizedDescription
                    ]
                    parameters.merge(($0.0 as NSError).plainUnderlyingErrors()) { a, _ in a }
//                    TJAnalyticsManager.trackEvent(
//                        withCategory: "SwiftyPurchaseManager",
//                        action: "Restore failed purchase",
//                        params: parameters,
//                        type: .mamoto,
//                        truncValue: 128
//                    )
                }
                if !result.restoredPurchases.isEmpty {
                    print("[SwiftyPurchaseManager] Has restored purchases;")
//                    TJAnalyticsManager.trackEvent(
//                        withCategory: "SwiftyPurchaseManager",
//                        action: "Has restored purchases",
//                        params: nil,
//                        type: .mamoto,
//                        truncValue: 128
//                    )
                }
                self.notificationCenter.post(name: .didRestore, object: nil)
                print("[SwiftyPurchaseManager] Finish restore;")
//                TJAnalyticsManager.trackEvent(
//                    withCategory: "SwiftyPurchaseManager",
//                    action: "Finish restore",
//                    params: nil,
//                    type: .mamoto,
//                    truncValue: 128
//                )
                self.refresh()
            }
        }
    }
    
    // MARK: - Static public func
    
    static public func refresh(with identifiers: [NSString], _ block: (() -> Void)? = nil) {
        var service: AppleReceiptValidator.VerifyReceiptURLType
        #if DEBUG
        service = .sandbox
        #else
        service = .production
        #endif
        print("[SwiftyPurchaseManager] Start refresh;")
//        TJAnalyticsManager.trackEvent(
//            withCategory: "SwiftyPurchaseManager",
//            action: "Start refresh",
//            params: [
//                "service" : "\(service.rawValue)"
//            ],
//            type: .mamoto,
//            truncValue: 128
//        )
        let validator = AppleReceiptValidator(
            service: service,
            sharedSecret: sharedSercret
        )
        SwiftyStoreKit.verifyReceipt(using: validator, forceRefresh: true) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let receipt):
                    var purchased = [(productId: String, expiryDate: Date)]()
                    for identifier in identifiers {
                        let productId = identifier as String
                        let result = SwiftyStoreKit.verifySubscription(
                            ofType: .autoRenewable,
                            productId: productId,
                            inReceipt: receipt
                        )
                        switch result {
                        case .purchased(let expiryDate, let items):
                            print("[SwiftyPurchaseManager] Verify subscription: \(productId) is purchased; expiryDate: \(expiryDate); items: \(items);")
                            purchased.append((productId, expiryDate))
                        case .expired(let expiryDate, let items):
                            print("[SwiftyPurchaseManager] Verify subscription: \(productId) is expired; expiryDate: \(expiryDate); items: \(items);")
                        case .notPurchased:
                            print("[SwiftyPurchaseManager] Verify subscription: \(productId) is not purchased;")
                        }
                    }
                    let sorted = purchased.sorted { $0.expiryDate < $1.expiryDate }
                    if let last = sorted.last {
                        print("[SwiftyPurchaseManager] Did find latest unexpired date; productId: \(last.productId); expiryDate \(last.expiryDate);")
//                        TJAnalyticsManager.trackEvent(
//                            withCategory: "SwiftyPurchaseManager",
//                            action: "Did find latest unexpired date",
//                            params: [
//                                "productId" : last.productId,
//                                "expiryDate" : "\(last.expiryDate)"
//                            ],
//                            type: .mamoto,
//                            truncValue: 128
//                        )
                        NotificationCenter.default.post(last.productId, true, last.expiryDate)
                    } else {
                        print("[SwiftyPurchaseManager] Did NOT find latest unexpired date;")
//                        TJAnalyticsManager.trackEvent(
//                            withCategory: "SwiftyPurchaseManager",
//                            action: "Did NOT find latest unexpired date",
//                            params: nil,
//                            type: .mamoto,
//                            truncValue: 128
//                        )
                        NotificationCenter.default.post("", false, Date(timeIntervalSince1970: 0))
                    }
                case .error(let error):
                    let nsError = error as NSError
                    print("[SwiftyPurchaseManager] Verify receipt error: \(nsError);")
//                    TJAnalyticsManager.trackEvent(
//                        withCategory: "SwiftyPurchaseManager",
//                        action: "Finish refresh",
//                        params: nsError.plainUnderlyingErrors(),
//                        type: .mamoto,
//                        truncValue: 128
//                    )
                    NotificationCenter.default.post(nsError)
                }
                print("[SwiftyPurchaseManager] Finish refresh;")
//                TJAnalyticsManager.trackEvent(
//                    withCategory: "SwiftyPurchaseManager",
//                    action: "Finish refresh",
//                    params: nil,
//                    type: .mamoto,
//                    truncValue: 128
//                )
                block?()
            }
        }
    }
}

internal extension NSError {
    
    func plainUnderlyingErrors(_ layer: Int = 0) -> [String : String] {
        var result = [String : String]()
        let layerString = "(Layer \(layer))"
        result["\(layerString) errorDomain"] = domain
        result["\(layerString) code"] = "\(code)"
        result["\(layerString) localizedDescription"] = localizedDescription
        if let underlyingError = userInfo[NSUnderlyingErrorKey] as? NSError {
            let underlyingPlain = underlyingError.plainUnderlyingErrors(layer + 1)
            result.merge(underlyingPlain) { a, _ in a }
        }
        return result
    }
}

extension ReceiptError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .noReceiptData:
            return nil
        case .noRemoteData:
            return nil
        case .networkError(let error):
            return error.localizedDescription
        case .receiptInvalid:
            return nil
        case .requestBodyEncodeError(let error):
            return error.localizedDescription
        case .jsonDecodeError:
            return nil
        }
    }
}
