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
import KeyboardAdjuster

public enum QuickTableViewRowBuilder {
    public typealias C = UITableViewCell
    public typealias QuickTableViewHandler = (UIViewController) -> Void

    case `default`(String?)
    case subtitle(String?, String?)
    case value1(String?, String?)
    case value2(String?, String?)
    case custom(QuickTableViewCellIdentifiable.Type, (C) -> C)

    indirect case rowWithSetup(QuickTableViewRowBuilder, (C) -> C)
    indirect case rowWithHandler(QuickTableViewRowBuilder, QuickTableViewHandler)
    indirect case rowWithHandler2(QuickTableViewRowBuilder, (UIViewController, CGPoint) -> Void)

    public func onSelection(_ handler: @escaping QuickTableViewHandler) -> QuickTableViewRowBuilder {
        if case .rowWithHandler(let row, _) = self {
            return .rowWithHandler(row, handler)
        } else {
            return .rowWithHandler(self, handler)
        }
    }

    public func dequeueReusableCellWithIdentifier(_ tableView: UITableView, forIndexPath indexPath: IndexPath) -> C {
        return prepareCell(tableView.dequeueReusableCell(withIdentifier: type.identifier, for: indexPath))
    }

    public func prepareCell(_ cell: C) -> C {
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = detail

        switch self {
        case .custom(_, let callback):
            return callback(cell)

        case .rowWithHandler(let row, _):
            return row.prepareCell(cell)

        case .rowWithHandler2(let row, _):
            return row.prepareCell(cell)

        case .rowWithSetup(let row, let callback):
            return row.prepareCell(callback(cell))

        default:
            break
        }
        return cell
    }

    public var title: String? {
        switch self {
        case .default(let title):
            return title

        case .subtitle(let title, _):
            return title

        case .value1(let title, _):
            return title

        case .value2(let title, _):
            return title

        case .custom:
            return nil

        case .rowWithSetup:
            return nil

        case .rowWithHandler(let row, _):
            return row.title

        case .rowWithHandler2(let row, _):
            return row.title
        }
    }

    public var detail: String? {
        switch self {
        case .default:
            return nil

        case .subtitle(_, let detail):
            return detail

        case .value1(_, let detail):
            return detail

        case .value2(_, let detail):
            return detail

        case .custom:
            return nil

        case .rowWithHandler(let row, _):
            return row.detail

        case .rowWithSetup:
            return nil

        case .rowWithHandler2(let row, _):
            return row.detail
        }
    }

    public var type: QuickTableViewCellIdentifiable.Type {
        switch self {
        case .default:
            return QuickTableViewCellDefault.self

        case .subtitle:
            return QuickTableViewCellSubtitle.self

        case .value1:
            return QuickTableViewCellValue1.self

        case .value2:
            return QuickTableViewCellValue2.self

        case .custom(let type, _):
            return type

        case .rowWithHandler(let row, _):
            return row.type

        case .rowWithSetup(let row, _):
            return row.type

        case .rowWithHandler2(let row, _):
            return row.type
        }
    }
}

public enum QuickTableViewSectionBuilder: ExpressibleByArrayLiteral {
    public typealias Row = QuickTableViewRowBuilder
    public typealias Element = Row
    var count: Int { return rows.count }

    case `default`([Row])
    case title(String, [Row])

    public init(name theName: String, rows theRows: [Row]) {
        self = .title(theName, theRows)
    }

    public init(_ rows: [Row]) {
        self = .default(rows)
    }

    public init(arrayLiteral elements: Element...) {
        self = .default(elements)
    }

    subscript(index: Int) -> Row {
        return rows[index]
    }

    var name: String? {
        guard case .title(let title, _) = self else {
            return nil
        }

        return title
    }

    var rows: [QuickTableViewRowBuilder] {
        switch self {
        case .default(let rows):
            return rows

        case .title(_, let rows):
            return rows
        }
    }

    var TableViewCellClasses: [QuickTableViewCellIdentifiable.Type] {
        return rows.map { $0.type }
    }
}

open class QuickTableViewController<Container: QuickTableViewContainer>: BaseTableViewController, UITableViewDataSource, UITableViewDelegate {
    required public init() {
        super.init(style: Container.style)

        if Container.shouldAutoResizeCells {
            tableView.estimatedRowHeight = 44
            tableView.rowHeight = UITableView.automaticDimension
        }
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        var registeredClassIdentifiers: Set<String> = Set()
        for section in Container.sections {
            for type in section.TableViewCellClasses {
                if !registeredClassIdentifiers.contains(type.identifier) {
                    tableView.registerClass(type)
                    registeredClassIdentifiers.insert(type.identifier)
                }
            }
        }
    }

    open func numberOfSections(in tableView: UITableView) -> Int {
        return Container.sections.count
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Container.sections[section].count
    }

    open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Container.sections[section].name
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = Container.sections[indexPath.section]
        let row = section.rows[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: row.type.identifier, for: indexPath)
        return row.prepareCell(cell)
    }

    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let section = Container.sections[indexPath.section]
        if case .rowWithHandler(_, let handler) = section[indexPath.row] {
            handler(self)
        } else if case .rowWithHandler2(_, let handler) = section[indexPath.row] {
            let rect = rectForRow(at: indexPath)
            let newRect = view.convert(rect, to: view)
            let maxX = newRect.maxX
            let midY = newRect.midY
            handler(self, CGPoint(x: maxX - 70, y: midY - tableView.contentOffset.y))
        }
    }

    open override func rightBarButtonItemDidTouchUpInside(_ sender: AnyObject?) {
        super.rightBarButtonItemDidTouchUpInside(sender)
    }

    open override func leftBarButtonItemDidTouchUpInside(_ sender: AnyObject?) {
        super.leftBarButtonItemDidTouchUpInside(sender)
    }
}
