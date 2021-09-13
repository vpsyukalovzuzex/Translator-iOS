//
//  CustomTableView.swift
//

import UIKit

class CustomTableView: UITableView {
    
    override var contentSize: CGSize { didSet { invalidateIntrinsicContentSize() } }
    
    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}
