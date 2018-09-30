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

import UIKit

public protocol QuickTableViewCellIdentifiable {
    static var identifier: String { get }
}

public protocol QuickTableViewCellIdentifiableFixedHeight: QuickTableViewCellIdentifiable { }

public protocol QuickTableViewCellIdentifiableAutomaticHeight: QuickTableViewCellIdentifiable { }

public protocol QuickTableViewContainer {
    static var sections: [QuickTableViewSectionBuilder] { get }
    static var style: UITableView.Style { get }
    static var shouldAutoResizeCells: Bool { get }
}

public protocol HasTableView {
    var tableView: UITableView! { get }
}

public protocol QuickTableViewSection { }

public protocol QuickTableViewSectionWithConditions: QuickTableViewSection {
    associatedtype Container
    static func conditionalSections(for container: Container) -> [(Self, Bool)]
}

public protocol QuickTableViewRow { }

public protocol QuickTableViewRowWithConditions: QuickTableViewRow {
    associatedtype Container
    static func conditionalRows(for container: Container) -> [(Self, Bool)]
}
