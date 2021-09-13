//
//  FactoryPurchaseManager.swift
//

import Foundation

@objc public class FactoryPurchaseManager: NSObject {
    
    private static var swifty: SwiftyPurchaseManager?
    
    @objc public static func purchaseManager(_ vendor: PurchaseManagerVendor) -> PurchaseManagerProtocol {
        switch vendor {
        case .swifty:
            if swifty == nil {
                swifty = SwiftyPurchaseManager()
            }
            return swifty!
        }
    }
}
