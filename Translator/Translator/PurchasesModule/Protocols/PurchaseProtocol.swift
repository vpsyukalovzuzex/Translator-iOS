//
//  PurchaseProtocol.swift
//

import Foundation

@objc public protocol PurchaseProtocol: NSCoding {
    
    var identifier: NSString { get }
    
    var price: NSString { get }
    
    var periodPrice: NSString { get }
    
    var analog: NSString? { get }
    
    var caption: NSString { get }
    
    func makePurchase()
}
