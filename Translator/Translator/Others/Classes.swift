//
//  Classes.swift
//

#if os(iOS)

import UIKit

private typealias Font = UIFont
private typealias Color = UIColor

private extension Font {
    
    static var font: Font {
        return Font(name: "SFProText-Regular", size: 16.0)!
    }
}

private extension Color {
    
    static var color: Color {
        return Color(named: "r_lexical_meaning_link")!
    }
}

#else

import Cocoa

private typealias Font = NSFont
private typealias Color = NSColor

private extension Font {
    
    static var font: Font { Font.systemFont(ofSize: 14.0) }
}

private extension Color {
    
    static var color: Color {
        if #available(OSX 10.13, *) {
            return Color(named: "r_mac_lexical_meaning_link")!
        } else {
            return .link
        }
    }
}

#endif

protocol Stringable {
    
    var string: String? { get }
}

protocol Substringable {
    
    var substring: String? { get }
}

class Main: Stringable, Substringable {
    
    var string: String?
    var substring: String?
    
    init(string: String?, substring: String?) {
        self.string = string
        self.substring = substring
    }
}

class Example: Stringable {
    
    var string: String?
    
    var isCanPlay: Bool
    
    init(string: String?, isCanPlay: Bool = true) {
        self.string = string
        self.isCanPlay = isCanPlay
    }
}

class LexicalExample: Example {}

class FromExample: Example {}

class ToExample: Example {}

class Info: Stringable {
    
    var string: String?
    
    init(string: String?) {
        self.string = string
    }
}

class NameInfo: Info {}

class DefinitionInfo: Info {}

class LexicalMeaningInfo: Info {
    
    var words: [String]?
    
    var attributedString: NSAttributedString {
        guard let words = words, !words.isEmpty else {
            return NSAttributedString()
        }
        let result = NSMutableAttributedString()
        let attributes: [NSAttributedString.Key : Any] = [
            .font : Font.font,
            .foregroundColor : Color.color
        ]
        let separator = NSAttributedString(string: ", ", attributes: attributes)
        var i = 0
        for word in words {
            var copyAttributes = attributes
            #if os(iOS)
            copyAttributes[.link] = "\(i)"
            #else
            copyAttributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
            #endif
            let attributedWord = NSAttributedString(
                string: word,
                attributes: copyAttributes
            )
            if words.count > 1, words.first != word || words.last == word {
                result.append(separator)
            }
            result.append(attributedWord)
            i += 1
        }
        return result
    }
    
    var ranges: [NSRange]? {
        guard let words = words else {
            return nil
        }
        var result = [NSRange]()
        var location = 0
        for i in 0..<words.count {
            let previous = word(by: i - 1)
            let current = word(by: i)
            location += (previous ?? "").count + (previous == nil ? 0 : 2) // 2 is ", "
            let range = NSRange(
                location: location,
                length: current?.count ?? 0
            )
            result.append(range)
        }
        return result
    }
    
    func word(by index: Int) -> String? {
        guard let words = words else {
            return nil
        }
        if 0 <= index && index < words.count {
            return words[index]
        }
        return nil
    }
}

class Header: Stringable {
    
    var string: String?
    
    init(string: String?) {
        self.string = string
    }
}
