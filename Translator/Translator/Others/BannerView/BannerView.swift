//
//  BannerView.swift
//

import UIKit

protocol BannerViewDelegate: AnyObject {
    
    func bannerViewDidTouchUpInside(_ bannerView: BannerView)
}

class BannerView: CustomView {
    
    weak var delegate: BannerViewDelegate?
    
    override func didLoad() {
        super.didLoad()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizer(_:))))
    }
    
    @objc private func tapGestureRecognizer(_ gestureRecognizer: UITapGestureRecognizer) {
        delegate?.bannerViewDidTouchUpInside(self)
    }
}
