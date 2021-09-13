//
//  LexicalMeaningTableViewCell.swift
//

import UIKit

protocol LexicalMeaningTableViewCellDelegate: AnyObject {
    
    func lexicalMeaningTableViewCell(_ lexicalMeaningTableViewCell: LexicalMeaningTableViewCell, didSelectWordAt index: Int)
}

class LexicalMeaningTableViewCell: UITableViewCell, Titled {
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var textView: UITextView!
    
    weak var delegate: LexicalMeaningTableViewCellDelegate?
    
    var attributedText: NSAttributedString {
        get { textView.attributedText }
        set { textView.attributedText = newValue }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.textContainerInset = .zero
        textView.linkTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(named: "r_lexical_meaning_link")!,
            NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue
        ]
    }
}

extension LexicalMeaningTableViewCell: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if let index = Int(URL.absoluteString) {
            delegate?.lexicalMeaningTableViewCell(self, didSelectWordAt: index)
        }
        return false
    }
}
