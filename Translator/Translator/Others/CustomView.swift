//
//  CustomView.swift
//

import UIKit

public class CustomView: UIView {
    
    public var contentView: UIView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromNib()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadFromNib()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
    }
    
    private func loadFromNib() {
        guard let name = NSStringFromClass(type(of: self)).components(separatedBy: ".").last else {
            return
        }
        let array = Bundle.main.loadNibNamed(name, owner: self, options: nil)
        contentView = array?.first as? UIView ?? UIView()
        addSubview(contentView)
        didLoad()
    }
    
    public func didLoad() {
        /* Abstract. */
    }
    
    public func setHidden(_ hidden: Bool, animated: Bool, completion: (() -> Void)? = nil) {
        let alpha: CGFloat = hidden ? 0.0 : 1.0
        if animated {
            UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut, animations: {
                self.alpha = alpha
            }, completion: { _ in
                completion?()
            })
        } else {
            self.alpha = alpha
            completion?()
        }
    }
}
