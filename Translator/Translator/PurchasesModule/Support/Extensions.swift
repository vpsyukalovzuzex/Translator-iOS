//
//  Extensions.swift
//

import Foundation
import StoreKit

enum ErrorType: Int {
    
    case undefined = 0
    case restored = 1
}

internal extension NotificationCenter {
    
    func post(_ error: Error, type: ErrorType = .undefined) {
        post(name: .didError, object: nil, userInfo: ["error" : error, "type" : type.rawValue])
    }
    
    func post(_ productIdentifier: String, _ isActive: Bool, _ expiredDate: Date) {
        post(name: .didRefresh, object: nil, userInfo: ["productIdentifier" : productIdentifier, "isActive" : isActive, "expiredDate" : expiredDate])
    }
}

internal extension Notification.Name {
    
    static let didRequest = Notification.Name("didRequest")
    static let didRefresh = Notification.Name("didRefresh")
    static let didRestore = Notification.Name("didRestore")
    static let didError = Notification.Name("didError")
    static let didPurchase = Notification.Name("didPurchase")
}

@objc public extension NSNotification {
    
    static var didRequest: NSString {
        return "didRequest"
    }
    
    static var didRefresh: NSString {
        return "didRefresh"
    }
    
    static var didRestore: NSString {
        return "didRestore"
    }
    
    static var didError: NSString {
        return "didError"
    }
    
    static var didPurchase: NSString {
        return "didPurchase"
    }
}

internal extension SKProduct {
    
    var resultPrice: String {
        let currency = priceLocale.currencyCode
        let formatter = NumberFormatter()
        formatter.positiveFormat = "0.##"
        if let price = formatter.string(from: price) {
            return price + (currency == nil ? "" : " \(currency!)")
        }
        return ""
    }
}
