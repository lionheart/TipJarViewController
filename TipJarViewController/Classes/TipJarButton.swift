//
//  TipJarButton.swift
//  TipJarViewController
//
//  Created by Dan Loewenherz on 5/6/18.
//

import UIKit

final class TipJarButton: UIButton {
    let disabledColor = UIColor.gray
    
    static var blue: UIColor {
        return UIColor(red: 0, green: 122/255, blue: 1, alpha: 1)
    }
    
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                layer.borderColor = TipJarButton.blue.cgColor
            } else {
                layer.borderColor = disabledColor.cgColor
            }
        }
    }
    
    init() {
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        clipsToBounds = true
        
        contentEdgeInsets = UIEdgeInsets(top: 3, left: 6, bottom: 3, right: 6)
        
        layer.cornerRadius = 6
        layer.borderColor = TipJarButton.blue.cgColor
        layer.borderWidth = 1
        
        setBackgroundImage(UIImage(color: .white), for: .normal)
        setBackgroundImage(UIImage(color: TipJarButton.blue), for: .highlighted)
        
        titleLabel?.numberOfLines = 0
        titleLabel?.lineBreakMode = .byWordWrapping
    }
    
    func setAmount(amount: String, frequency: TipJarFrequency) {
        let string = NSMutableAttributedString()
        string.append(NSAttributedString(string: amount + "\n", attributes: [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
            ]))
        string.append(NSAttributedString(string: frequency.description, attributes: [
            .font: UIFont.systemFont(ofSize: 13, weight: .regular)
            ]))
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.setParagraphStyle(NSParagraphStyle.default)
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.alignment = .center
        
        string.addAttribute(.paragraphStyle, value: paragraphStyle)
        string.addAttribute(.foregroundColor, value: TipJarButton.blue)
        setAttributedTitle(string, for: .normal)
        
        let highlightedString = NSMutableAttributedString(attributedString: string)
        highlightedString.addAttribute(.foregroundColor, value: UIColor.white)
        setAttributedTitle(highlightedString, for: .highlighted)
        
        let disabledString = NSMutableAttributedString(attributedString: string)
        disabledString.addAttribute(.foregroundColor, value: disabledColor)
        setAttributedTitle(disabledString, for: .disabled)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
