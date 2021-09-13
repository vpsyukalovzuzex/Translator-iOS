//
//  TitleTableViewCell.swift
//

import UIKit

protocol Titled: UITableViewCell {
    
    var titleLabel: UILabel! { get }
}

extension Titled {
    
    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }
}

class TitleTableViewCell: UITableViewCell, Titled {
    
    @IBOutlet var titleLabel: UILabel!
}

class NameTableViewCell: TitleTableViewCell {}

class DefinitionTableViewCell: TitleTableViewCell {}
