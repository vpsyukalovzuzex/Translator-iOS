//
//  SwiftyPurchase.swift
//

import Foundation
import StoreKit
import SwiftyStoreKit

@objc internal class SwiftyPurchase: Purchase {
    
    // MARK: - Override func
    
    override func makePurchase() {
        let productId = identifier as String
        print("[SwiftyPurchase] Start make purchase: \(productId);")
//        TJAnalyticsManager.trackEvent(
//            withCategory: "SwiftyPurchase",
//            action: "Start make purchase",
//            params: [
//                "productId" : productId
//            ],
//            type: .mamoto,
//            truncValue: 128
//        )
        super.makePurchase()
        SwiftyStoreKit.purchaseProduct(productId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }
                switch result {
                case .success:
                    print("[SwiftyPurchase] Make purchase success: \(productId);")
//                    TJAnalyticsManager.trackEvent(
//                        withCategory: "SwiftyPurchase",
//                        action: "Make purchase success",
//                        params: [
//                            "productId" : productId
//                        ],
//                        type: .mamoto,
//                        truncValue: 128
//                    )
                    self.notificationCenter.post(name: .didPurchase, object: nil)
                    SwiftyPurchaseManager.refresh(with: [productId as NSString])
                case .error(let error):
                    let nsError = error as NSError
                    print("[SwiftyPurchase] Make purchase error: \(nsError);")
//                    TJAnalyticsManager.trackEvent(
//                        withCategory: "SwiftyPurchase",
//                        action: "Make purchase error",
//                        params: nsError.plainUnderlyingErrors(),
//                        type: .mamoto,
//                        truncValue: 128
//                    )
                    self.notificationCenter.post(error)
                }
                print("[SwiftyPurchase] Finish make purchase: \(productId);")
//                TJAnalyticsManager.trackEvent(
//                    withCategory: "SwiftyPurchase",
//                    action: "Finish make purchase",
//                    params: [
//                        "productId" : productId
//                    ],
//                    type: .mamoto,
//                    truncValue: 128
//                )
            }
        }
    }
}
