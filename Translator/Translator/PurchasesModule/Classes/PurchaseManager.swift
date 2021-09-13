//
//  PurchaseManager.swift
//

import Foundation
import StoreKit

private extension String {
    
    static let identifiersKey = "identifiersKey"
}

@objc internal class PurchaseManager: NSObject, PurchaseManagerProtocol, NotificationCenterProtocol {
    
    var parameters = NSDictionary()
    
    var purchases = [PurchaseProtocol]()
    
    var info = [PurchaseInfo]()
    
    var deviceToken: Data?
    
    // MARK: - Public
    
    public func setup(parameters: NSDictionary, info: [PurchaseInfo]) {
        self.parameters = parameters
        self.info = info
    }
    
    public func request() {
        if self.purchases.isEmpty, let purchases = load() {
            self.purchases = purchases
        }
    }
    
    public func save() {
        let data = NSKeyedArchiver.archivedData(withRootObject: purchases)
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(data, forKey: .identifiersKey)
        userDefaults.synchronize()
    }
    
    public func load() -> [PurchaseProtocol]? {
        if let data = UserDefaults.standard.data(forKey: .identifiersKey) {
            return NSKeyedUnarchiver.unarchiveObject(with: data) as? [PurchaseProtocol]
        }
        return nil
    }
    
    public func purchase(by identifier: NSString) -> PurchaseProtocol? {
        return purchases.first { ($0.identifier as String) == (identifier as String) }
    }
    
    // MARK: - Abstract
    
    public func refresh() {
        /* Abstract. */
    }
    
    public func refresh(with block: (() -> Void)?) {
        /* Abstract. */
    }
    
    public func restore() {
        /* Abstract. */
    }
    
    // MARK: - Internal
    
    internal func purchaseInfo(by identifier: String) -> PurchaseInfo? {
        return info.first { ($0.identifier as String) == identifier }
    }
}
