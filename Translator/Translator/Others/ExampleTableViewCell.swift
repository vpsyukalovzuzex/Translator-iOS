//
//  ExampleTableViewCell.swift
//

import UIKit
import Common

protocol ExampleTableViewCellDelegate: AnyObject {
    
    func exampleTableViewCell(_ exampleTableViewCell: ExampleTableViewCell, didPlay button: UIButton)
}

class ExampleTableViewCell: UITableViewCell {
    
    var allTextColor: UIColor { .black }
    var highlightTextColor: UIColor { .black }
    
    @IBOutlet private weak var titleLabel: UILabel!
    
    @IBOutlet private weak var playButton: UIButton!
    
    var isCanPlay: Bool {
        get { !playButton.isHidden }
        set { playButton.isHidden = !newValue }
    }
    
    weak var delegate: ExampleTableViewCellDelegate?
    
    func setup(word: String?, text: String?) {
        let regularFont = UIFont(name: "SFProText-Regular", size: 16.0)!
        let semiboldFont = UIFont(name: "SFProText-Semibold", size: 16.0)!
        let textAttributes: [NSAttributedString.Key : Any] = [
            .foregroundColor : allTextColor,
            .font : regularFont
        ]
        let highlightAttributes: [NSAttributedString.Key : Any] = [
            .foregroundColor : highlightTextColor,
            .font : semiboldFont
        ]
        let string = NSMutableAttributedString(string: text ?? "", attributes: textAttributes)
        if let word = word, let text = text {
            let ranges = text.ranges(of: word, options: .caseInsensitive, locale: nil)
            for range in ranges {
                let nsRange = NSRange(range, in: text)
                string.addAttributes(highlightAttributes, range: nsRange)
            }
        }
        titleLabel.attributedText = string
    }
    
    @IBAction func playButtonTouchUpInsideAction(_ sender: UIButton) {
        delegate?.exampleTableViewCell(self, didPlay: sender)
    }
}

class ExampleBlueTableViewCell: ExampleTableViewCell {
    
    override var allTextColor: UIColor { UIColor(named: "r_example_original")! }
    override var highlightTextColor: UIColor { UIColor(named: "r_example_original_word")! }
}

class ExampleGrayTableViewCell: ExampleTableViewCell {
    
    override var allTextColor: UIColor { UIColor(named: "r_example_translated")! }
    override var highlightTextColor: UIColor { UIColor(named: "r_example_translated_word")! }
}

class ExampleBrownTableViewCell: ExampleTableViewCell {
    
    override var allTextColor: UIColor { UIColor(named: "r_example_lexical_meaning")! }
    override var highlightTextColor: UIColor { UIColor(named: "r_example_lexical_meaning_word")! }
}

class HeaderTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
    
    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }
}
