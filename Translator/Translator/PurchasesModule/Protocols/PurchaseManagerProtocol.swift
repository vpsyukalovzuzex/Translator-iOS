//
//  PurchaseManagerProtocol.swift
//

import Foundation

@objc public protocol PurchaseManagerProtocol {
    
    var parameters: NSDictionary { get }
    
    var purchases: [PurchaseProtocol] { get }
    
    var deviceToken: Data? { get set }
    
    func setup(parameters: NSDictionary, info: [PurchaseInfo])
    
    func request()
    
    func refresh()
    
    func refresh(with block: (() -> Void)?)
    
    func restore()
    
    func purchase(by identifier: NSString) -> PurchaseProtocol?
}
