//
//  NotificationCenterProtocol.swift
//

import Foundation

internal protocol NotificationCenterProtocol {
    
    var notificationCenter: NotificationCenter { get }
}

extension NotificationCenterProtocol {
    
    var notificationCenter: NotificationCenter {
        return NotificationCenter.default
    }
}
