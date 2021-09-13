//
//  Purchase.swift
//

import Foundation

private extension String {
    
    static let identifierKey = "identifierKey"
    static let priceKey = "priceKey"
    static let periodPriceKey = "periodPriceKey"
    static let analogKey = "analogKey"
}

@objc internal class Purchase: NSObject, PurchaseProtocol, NotificationCenterProtocol {
    
    var identifier: NSString
    var price: NSString
    var periodPrice: NSString
    
    var analog: NSString?
    
    var caption: NSString {
        let isMax = false // TJSettingsService.defaultSettings()?.remoteSettings?.showMaxConversionPurchaseScreen?.boolValue ?? false
        return isMax ? ((analog ?? "").length > 0 ? analog! : price) : price
    }
    
    // MARK: - Init
    
    @objc public init(identifier: NSString, price: NSString, periodPrice: NSString, analog: NSString? = nil) {
        self.identifier = identifier
        self.price = price
        self.periodPrice = periodPrice
        self.analog = analog
        super.init()
    }
    
    // MARK: - Abstract
    
    func makePurchase() {
        /* Abstract. */
    }
    
    // MARK: - NSCoding
    
    required convenience init?(coder: NSCoder) {
        let defaultString = NSString()
        let identifier = coder.decodeObject(forKey: .identifierKey) as? NSString ?? defaultString
        let price = coder.decodeObject(forKey: .priceKey) as? NSString ?? defaultString
        let periodPrice = coder.decodeObject(forKey: .periodPriceKey) as? NSString ?? defaultString
        let analog = coder.decodeObject(forKey: .analogKey) as? NSString ?? defaultString
        self.init(identifier: identifier, price: price, periodPrice: periodPrice, analog: analog)
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(identifier, forKey: .identifierKey)
        coder.encode(price, forKey: .priceKey)
        coder.encode(periodPrice, forKey: .periodPriceKey)
        coder.encode(analog, forKey: .analogKey)
    }
}
