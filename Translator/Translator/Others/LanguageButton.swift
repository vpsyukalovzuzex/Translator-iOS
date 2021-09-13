//
//  LanguageButton.swift
//

import UIKit

class LanguageButton: UIControl {
    
    // MARK: - Constants
    
    private let spacing: CGFloat = 8.0
    
    // MARK: - Private
    
    public var imageView = UIImageView()
    
    private var label = UILabel()
    
    private var expandImageView = UIImageView()
    
    // MARK: - Public
    
    public var image: UIImage? {
        get { imageView.image }
        set { imageView.image = newValue }
    }
    
    public var title: String? {
        get { label.text }
        set { label.text = newValue }
    }
    
    public var textColor: UIColor {
        get { label.textColor }
        set { label.textColor = newValue }
    }
    
    public var expandColor: UIColor {
        get { expandImageView.tintColor }
        set { expandImageView.tintColor = newValue }
    }
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    // MARK: - Private
    
    private func setup() {
        backgroundColor = .clear
        setupLabel()
        setupImageView()
        setupExpandImageView()
        setupTapGestureRecognizer()
        construct()
    }
    
    private func setupLabel() {
        textColor = .black
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.font = UIFont(name: "SFProText-Semibold", size: 16.0)
    }
    
    private func setupImageView() {
        let size: CGFloat = 32.0
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let attributes: [NSLayoutConstraint.Attribute] = [.width, .height]
        for attribute in attributes {
            imageView.addConstraint(
                NSLayoutConstraint(
                    item: imageView,
                    attribute: attribute,
                    relatedBy: .equal,
                    toItem: nil,
                    attribute: .notAnAttribute,
                    multiplier: 1.0,
                    constant: size
                )
            )
        }
        imageView.layer.cornerRadius = 0.5 * size
        imageView.layer.masksToBounds = true
    }
    
    private func setupExpandImageView() {
        let size: CGFloat = 12.0
        expandColor = .black
        expandImageView.image = UIImage(named: "r_language_expand")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let attributes: [NSLayoutConstraint.Attribute] = [.width, .height]
        for attribute in attributes {
            expandImageView.addConstraint(
                NSLayoutConstraint(
                    item: expandImageView,
                    attribute: attribute,
                    relatedBy: .equal,
                    toItem: nil,
                    attribute: .notAnAttribute,
                    multiplier: 1.0,
                    constant: size
                )
            )
        }
    }
    
    private func setupTapGestureRecognizer() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizer(_:))))
    }
    
    private func construct() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = spacing
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(expandImageView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        let attributes: [NSLayoutConstraint.Attribute] = [.top, .right, .bottom, .left]
        for attribute in attributes {
            addConstraint(
                NSLayoutConstraint(
                    item: self,
                    attribute: attribute,
                    relatedBy: .equal,
                    toItem: stackView,
                    attribute: attribute,
                    multiplier: 1.0,
                    constant: 0.0
                )
            )
        }
    }
    
    @objc private func tapGestureRecognizer(_ sender: UITapGestureRecognizer) {
        sendActions(for: .touchUpInside)
    }
}
