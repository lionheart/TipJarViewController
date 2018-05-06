//
//  Copyright 2016 Lionheart Software LLC
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//

import KeyboardAdjuster
import UIKit

/**
 A base table view with built-in support for keyboard display and same initialization defaults.

 - author: Daniel Loewenherz
 - copyright: ©2016 Lionheart Software LLC
 - date: April 12, 2016
 */
open class BaseTableViewController: UIViewController, HasTableView {
    open var tableViewTopConstraint: NSLayoutConstraint!
    open var tableViewLeftConstraint: NSLayoutConstraint!
    open var tableViewRightConstraint: NSLayoutConstraint!

    open var tableView: UITableView!

    public init(style: UITableViewStyle = .grouped) {
        super.init(nibName: nil, bundle: nil)

        edgesForExtendedLayout = []
        definesPresentationContext = true

        tableView = UITableView(frame: CGRect.zero, style: style)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self as? UITableViewDelegate
        tableView.dataSource = self as? UITableViewDataSource

        if #available(iOS 11, *) {
            // Handle odd content inset adjustment animation on iOS 11
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // iOS 11 and below need to have auto-layout specified manually
            tableView.estimatedRowHeight = 44
            tableView.rowHeight = UITableViewAutomaticDimension
        }
    }

    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)

        tableViewLeftConstraint = tableView.leftAnchor.constraint(equalTo: view.leftAnchor)
        tableViewRightConstraint = tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        tableViewTopConstraint = tableView.topAnchor.constraint(equalTo: view.topAnchor)

        tableViewLeftConstraint.isActive = true
        tableViewTopConstraint.isActive = true
        tableViewRightConstraint.isActive = true
        tableView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor).isActive = true
        tableView.bottomAnchor.constraint(greaterThanOrEqualTo: keyboardLayoutGuide.topAnchor).isActive = true
    }

    // MARK: -
    @objc open func leftBarButtonItemDidTouchUpInside(_ sender: AnyObject?) {
        parent?.dismiss(animated: true, completion: nil)
    }

    @objc open func rightBarButtonItemDidTouchUpInside(_ sender: AnyObject?) {
        parent?.dismiss(animated: true, completion: nil)
    }

    open func rectForRow(at indexPath: IndexPath) -> CGRect {
        let rect = tableView.rectForRow(at: indexPath)
        return tableView.convert(rect, to: view)
    }
}
