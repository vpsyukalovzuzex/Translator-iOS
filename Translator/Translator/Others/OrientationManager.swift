//
// OrientationManager.swift
//

import UIKit
import CoreMotion

protocol OrientationManagerDelegate: AnyObject {
    
    func orientationManager(_ orientationManager: OrientationManager, didChange deviceOrientation: UIDeviceOrientation)
}

class OrientationManager {
    
    private let motionManager = CMMotionManager()
    
    private var deviceOrientation = UIDeviceOrientation.unknown
    
    weak var delegate: OrientationManagerDelegate?
    
    init() {
        motionManager.accelerometerUpdateInterval = 0.25
    }
    
    func start() {
        guard motionManager.isDeviceMotionAvailable else {
            return
        }
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            
            guard
                let self = self,
                let acceleration = data?.acceleration,
                error == nil
            else {
                return
            }
            
            var result = self.deviceOrientation
            
            let x = -acceleration.x
            let y =  acceleration.y
            let z =  acceleration.z
            
            let angle = atan2(y, x)
            
            if result == .faceUp || result == .faceDown {
                
                if fabs(z) < 0.845 {
                    if angle < -2.6 {
                        result = .landscapeRight
                    } else if angle > -2.05 && angle < -1.1 {
                        result = .portrait
                    } else if angle > -0.48 && angle < 0.48 {
                        result = .landscapeLeft
                    } else if angle > 1.08 && angle < 2.08 {
                        result = .portraitUpsideDown
                    }
                } else if z < 0 {
                    result = .faceUp
                } else if z > 0 {
                    result = .faceDown
                }
                
            } else {
                
                if z > 0.875 {
                    result = .faceDown
                } else if z < -0.875 {
                    result = .faceUp
                } else {
                    switch result {
                    case .landscapeLeft:
                        if angle < -1.07 {
                            result = .portrait
                        }
                        if angle > 1.08 {
                            result = .portraitUpsideDown
                        }
                    case .landscapeRight:
                        if angle < 0 && angle > -2.05 {
                            result = .portrait
                        }
                        if angle > 0 && angle < 2.05 {
                            result = .portraitUpsideDown
                        }
                    case .portraitUpsideDown:
                        if angle > 2.66 {
                            result = .landscapeRight
                        }
                        if angle < 0.48 {
                            result = .landscapeLeft
                        }
                    case .portrait:
                        if angle > -0.47 {
                            result = .landscapeLeft
                        }
                        if angle < -2.64 {
                            result = .landscapeRight
                        }
                    default:
                        if angle > -0.47 {
                            result = .landscapeLeft
                        }
                        if angle < -2.64 {
                            result = .landscapeRight
                        }
                    }
                }
                
            }
            
            if self.deviceOrientation != result {
                self.deviceOrientation = result
                self.delegate?.orientationManager(self, didChange: result)
            }
            
        }
    }
    
    func stop() {
        motionManager.stopAccelerometerUpdates()
    }
}
