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

import UIKit

public extension QuickTableViewSection where Self: RawRepresentable, Self.RawValue == Int {
    init(at indexPath: IndexPath) {
        self.init(at: indexPath.section)
    }

    init(at row: Int) {
        self.init(rawValue: row)!
    }

    static var count: Int {
        return lastSection.rawValue + 1
    }

    static var lastSection: Self {
        var section = Self(rawValue: 0)!
        for i in 0..<Int.max {
            guard let _section = Self(rawValue: i) else {
                return section
            }

            section = _section
        }

        return section
    }
}

public extension QuickTableViewSectionWithConditions where Self: RawRepresentable, Self.RawValue == Int {
    init(at indexPath: IndexPath, container: Container) {
        self.init(section: indexPath.section, container: container)
    }

    init(section: Int, container: Container) {
        var section = section
        let _conditionalRows = Self.conditionalSections(for: container)
        for (conditionalRow, test) in _conditionalRows {
            if section >= conditionalRow.rawValue && !test {
                section += 1
            }
        }
        self.init(rawValue: section)!
    }

    static func index(section: Self, container: Container) -> Int? {
        for i in 0..<count(for: container) {
            if section == Self(section: i, container: container) {
                return i
            }
        }

        return nil
    }

    static func count(for container: Container) -> Int {
        var count = lastSection.rawValue + 1
        let _conditionalRows = conditionalSections(for: container)
        for (_, test) in _conditionalRows {
            if !test {
                count -= 1
            }
        }
        return count
    }
}
