//
//  MultilineTableViewCell.swift
//
//  Created by Daniel Loewenherz on 10/21/17.
//  Copyright © 2017 Lionheart Software. All rights reserved.
//

import UIKit
import QuickTableView
import SuperLayout

final class MultilineTableViewCell: UITableViewCell {
    var theTextLabel: UILabel!
    var theDetailTextLabel: UILabel!
    
    override var textLabel: UILabel? { return theTextLabel }
    override var detailTextLabel: UILabel? { return theDetailTextLabel }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        theTextLabel = UILabel()
        theTextLabel.numberOfLines = 0
        theTextLabel.lineBreakMode = .byWordWrapping
        theTextLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        theTextLabel.translatesAutoresizingMaskIntoConstraints = false
        theTextLabel.textColor = .label
        theTextLabel.textAlignment = .left
        
        theDetailTextLabel = UILabel()
        theDetailTextLabel.numberOfLines = 0
        theDetailTextLabel.lineBreakMode = .byWordWrapping
        theDetailTextLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        theDetailTextLabel.translatesAutoresizingMaskIntoConstraints = false
        theDetailTextLabel.textColor = .secondaryLabel
        theDetailTextLabel.textAlignment = .left
        
        contentView.addSubview(theTextLabel)
        contentView.addSubview(theDetailTextLabel)
        
        let margins = contentView.layoutMarginsGuide
        
        theTextLabel.topAnchor ~~ margins.topAnchor
        theTextLabel.leadingAnchor ~~ margins.leadingAnchor
        
        theDetailTextLabel.topAnchor ~~ theTextLabel.bottomAnchor
        theDetailTextLabel.leadingAnchor ~~ margins.leadingAnchor
        theDetailTextLabel.bottomAnchor ~~ margins.bottomAnchor
        
        theTextLabel.trailingAnchor ~~ margins.trailingAnchor
        theDetailTextLabel.trailingAnchor ~~ margins.trailingAnchor
        
        updateConstraintsIfNeeded()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MultilineTableViewCell: QuickTableViewCellIdentifiable {
    static var identifier: String { return "MultilineTableViewCellIdentifier" }
}
