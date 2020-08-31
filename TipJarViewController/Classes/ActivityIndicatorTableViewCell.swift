//
//  ActivityIndicatorTableViewCell.swift
//
//  Created by Daniel Loewenherz on 10/21/17.
//  Copyright © 2017 Lionheart Software. All rights reserved.
//

import Foundation

import UIKit
import QuickTableView
import SuperLayout

final class ActivityIndicatorTableViewCell: UITableViewCell {
    var activityIndicator: UIActivityIndicatorView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        textLabel?.text = "Loading..."
        
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.startAnimating()
        
        accessoryView = activityIndicator
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ActivityIndicatorTableViewCell: QuickTableViewCellIdentifiable {
    static var identifier: String { return "ActivityIndicatorTableViewCellIdentifier" }
}
