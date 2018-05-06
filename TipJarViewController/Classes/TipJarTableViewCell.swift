//
//  TipJarTableViewCell.swift
//
//  Created by Daniel Loewenherz on 10/20/17.
//  Copyright © 2017 Lionheart Software. All rights reserved.
//

import UIKit
import QuickTableView
import SuperLayout
import LionheartExtensions

final class TipJarTableViewCell: UITableViewCell {
    var theTextLabel: UILabel!
    var theDetailTextLabel: UILabel!
    var tipJarButton: TipJarButton!
    
    var rightConstraints: [NSLayoutConstraint] = []
    
    override var textLabel: UILabel? { return theTextLabel }
    override var detailTextLabel: UILabel? { return theDetailTextLabel }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        accessoryType = .none
        
        theTextLabel = UILabel()
        theTextLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        theTextLabel.translatesAutoresizingMaskIntoConstraints = false
        theTextLabel.textColor = .black
        theTextLabel.textAlignment = .left
        
        theDetailTextLabel = UILabel()
        theDetailTextLabel.numberOfLines = 0
        theDetailTextLabel.lineBreakMode = .byWordWrapping
        theDetailTextLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        theDetailTextLabel.translatesAutoresizingMaskIntoConstraints = false
        theDetailTextLabel.textColor = .darkGray
        theDetailTextLabel.textAlignment = .left
        
        tipJarButton = TipJarButton()
        
        contentView.addSubview(theTextLabel)
        contentView.addSubview(theDetailTextLabel)
        contentView.addSubview(tipJarButton)
        
        let margins = contentView.layoutMarginsGuide
        
        theTextLabel.topAnchor ~~ margins.topAnchor
        theTextLabel.leadingAnchor ~~ margins.leadingAnchor
        
        theDetailTextLabel.topAnchor ~~ theTextLabel.bottomAnchor
        theDetailTextLabel.leadingAnchor ~~ margins.leadingAnchor
        theDetailTextLabel.bottomAnchor ~~ margins.bottomAnchor
        
        theTextLabel.rightAnchor ≤≤ tipJarButton.leftAnchor - 10
        theDetailTextLabel.rightAnchor ≤≤ tipJarButton.leftAnchor - 10
        
        tipJarButton.centerYAnchor ~~ margins.centerYAnchor
        tipJarButton.trailingAnchor ~~ margins.trailingAnchor
        tipJarButton.bottomAnchor ≤≤ margins.bottomAnchor
        
        tipJarButton.widthAnchor ~~ 70
        
        updateConstraintsIfNeeded()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepare(amount: String, frequency: TipJarFrequency) {
        tipJarButton.setAmount(amount: amount, frequency: frequency)
    }
}

extension TipJarTableViewCell: QuickTableViewCellIdentifiable {
    static var identifier: String { return "TipJarTableViewCellIdentifier" }
}
