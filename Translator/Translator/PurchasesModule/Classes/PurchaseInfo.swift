//
//  PurchaseInfo.swift
//

import Foundation

@objc public class PurchaseInfo: NSObject {
    
    public var identifier: NSString
    
    public var localizedPeriod: NSString
    
    public var localizedShortPeriod: NSString
    
    public var localizedAnalog: NSString?
    
    @objc public init(identifier: NSString, localizedPeriod: NSString, localizedShortPeriod: NSString, localizedAnalog: NSString?) {
        self.identifier = identifier
        self.localizedPeriod = localizedPeriod
        self.localizedShortPeriod = localizedShortPeriod
        self.localizedAnalog = localizedAnalog
        super.init()
    }
}
