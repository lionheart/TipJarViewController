//  Copyright 2017 Lionheart Software LLC
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

precedencegroup ConstraintPrecedence {
    lowerThan: AdditionPrecedence
    higherThan: AssignmentPrecedence
    associativity: left
    assignment: false
}

infix operator ~~: ConstraintPrecedence
infix operator ≥≥: ConstraintPrecedence
infix operator ≤≤: ConstraintPrecedence

public protocol AxisAnchoring {
    associatedtype AnchorType

    var constant: CGFloat { get }
    var anchor: AnchorType { get }
}

public protocol DimensionAnchoring: AxisAnchoring {
    var multiplier: CGFloat { get }
}

// MARK: - Protocol Extension

public extension AxisAnchoring {
    static func +(lhs: Self, rhs: CGFloat) -> LayoutContainer<AnchorType> {
        return LayoutContainer(anchor: lhs, constant: rhs)
    }

    static func -(lhs: Self, rhs: CGFloat) -> LayoutContainer<AnchorType> {
        return LayoutContainer(anchor: lhs, constant: -rhs)
    }
}

public extension DimensionAnchoring {
    static func *(lhs: Self, rhs: CGFloat) -> LayoutContainer<AnchorType> {
        return LayoutContainer(anchor: lhs, multiplier: rhs)
    }
}

// MARK: - Protocol Helpers

public protocol AxisAnchoringWithMethods: AxisAnchoring {
    func constraint(equalTo: AnchorType, constant: CGFloat) -> NSLayoutConstraint
    func constraint(lessThanOrEqualTo: AnchorType, constant: CGFloat) -> NSLayoutConstraint
    func constraint(greaterThanOrEqualTo: AnchorType, constant: CGFloat) -> NSLayoutConstraint
}

public protocol DimensionAnchoringWithMethods: DimensionAnchoring {
    func constraint(equalToConstant: CGFloat) -> NSLayoutConstraint
    func constraint(lessThanOrEqualToConstant: CGFloat) -> NSLayoutConstraint
    func constraint(greaterThanOrEqualToConstant: CGFloat) -> NSLayoutConstraint

    func constraint(equalTo: AnchorType, multiplier: CGFloat, constant: CGFloat) -> NSLayoutConstraint
    func constraint(lessThanOrEqualTo: AnchorType, multiplier: CGFloat, constant: CGFloat) -> NSLayoutConstraint
    func constraint(greaterThanOrEqualTo: AnchorType, multiplier: CGFloat, constant: CGFloat) -> NSLayoutConstraint
}

// MARK:

public struct LayoutContainer<U>: DimensionAnchoring {
    public typealias AnchorType = U

    public var multiplier: CGFloat
    public var constant: CGFloat
    public var anchor: AnchorType

    init<T: DimensionAnchoring>(anchor: T, constant: CGFloat) where T.AnchorType == AnchorType {
        self.constant = constant
        self.multiplier = anchor.multiplier
        self.anchor = anchor.anchor
    }

    init<T: DimensionAnchoring>(anchor: T, multiplier: CGFloat) where T.AnchorType == AnchorType {
        self.constant = anchor.constant
        self.multiplier = multiplier
        self.anchor = anchor.anchor
    }

    init<T: AxisAnchoring>(anchor: T, constant: CGFloat) where T.AnchorType == AnchorType {
        self.constant = constant
        self.multiplier = 1
        self.anchor = anchor.anchor
    }
}

extension NSLayoutYAxisAnchor: AxisAnchoringWithMethods {
    public typealias AnchorType = NSLayoutAnchor<NSLayoutYAxisAnchor>

    public var constant: CGFloat { return 0 }
    public var anchor: AnchorType { return self }
}

extension NSLayoutXAxisAnchor: AxisAnchoringWithMethods {
    public typealias AnchorType = NSLayoutAnchor<NSLayoutXAxisAnchor>

    public var constant: CGFloat { return 0 }
    public var anchor: AnchorType { return self }
}

extension NSLayoutDimension: DimensionAnchoringWithMethods {
    public typealias AnchorType = NSLayoutDimension

    public var multiplier: CGFloat { return 1 }
    public var constant: CGFloat { return 0 }
    public var anchor: AnchorType { return self }
}

public extension DimensionAnchoringWithMethods {
    /// Returns a constraint that defines the anchor’s size attribute as equal to the specified size attribute multiplied by a constant plus an offset.
    ///
    /// - Parameters:
    ///   - lhs: A dimension anchor from a `UIView`, `NSView`, or `UILayoutGuide` object.
    ///   - rhs: See `lhs`.
    /// - Returns: An `NSLayoutConstraint` object that defines the attribute represented by this layout anchor as equal to the attribute represented by the anchor parameter multiplied by an optional m constant plus an optional constant c.
    @discardableResult
    static func ~~<T: DimensionAnchoring>(lhs: Self, rhs: T) -> NSLayoutConstraint where T.AnchorType == AnchorType {
        let constraint = lhs.constraint(equalTo: rhs.anchor, multiplier: rhs.multiplier, constant: rhs.constant)
        constraint.isActive = true
        return constraint
    }

    /// Returns a constraint that defines the anchor’s size attribute as greater than or equal to the specified anchor multiplied by the constant plus an offset.
    ///
    /// - Parameters:
    ///   - lhs: A dimension anchor from a `UIView`, `NSView`, or `UILayoutGuide` object.
    ///   - rhs: See `lhs`.
    /// - Returns: An `NSLayoutConstraint` object that defines the attribute represented by this layout anchor as less than or equal to the attribute represented by the anchor parameter multiplied by an optional m constant plus an optional constant c.
    @discardableResult
    static func ≤≤<T: DimensionAnchoring>(lhs: Self, rhs: T) -> NSLayoutConstraint where T.AnchorType == AnchorType {
        let constraint = lhs.constraint(lessThanOrEqualTo: rhs.anchor, multiplier: rhs.multiplier, constant: rhs.constant)
        constraint.isActive = true
        return constraint
    }

    /// Returns a constraint that defines the anchor’s size attribute as greater than or equal to the specified anchor multiplied by the constant plus an offset.
    ///
    /// - Parameters:
    ///   - lhs: A dimension anchor from a `UIView`, `NSView`, or `UILayoutGuide` object.
    ///   - rhs: See `lhs`.
    /// - Returns: An NSLayoutConstraint object that defines the attribute represented by this layout anchor as greater than or equal to the attribute represented by the anchor parameter multiplied by an optional m constant plus an optional constant c.
    @discardableResult
    static func ≥≥<T: DimensionAnchoring>(lhs: Self, rhs: T) -> NSLayoutConstraint where T.AnchorType == AnchorType {
        let constraint = lhs.constraint(greaterThanOrEqualTo: rhs.anchor, multiplier: rhs.multiplier, constant: rhs.constant)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    static func ~~(lhs: Self, rhs: CGFloat) -> NSLayoutConstraint {
        let constraint = lhs.constraint(equalToConstant: rhs)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    static func ≤≤(lhs: Self, rhs: CGFloat) -> NSLayoutConstraint {
        let constraint = lhs.constraint(lessThanOrEqualToConstant: rhs)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    static func ≥≥(lhs: Self, rhs: CGFloat) -> NSLayoutConstraint {
        let constraint = lhs.constraint(greaterThanOrEqualToConstant: rhs)
        constraint.isActive = true
        return constraint
    }
}

public extension AxisAnchoringWithMethods {
    /// Returns a constraint that defines one item’s attribute as equal to another item’s attribute plus an optional constant offset.
    ///
    /// - Parameters:
    ///   - lhs: A layout anchor from a `UIView`, `NSView`, or `UILayoutGuide` object. You must use a subclass of NSLayoutAnchor that matches the current anchor. For example, if you call this method on an `NSLayoutXAxisAnchor` object, this parameter must be another `NSLayoutXAxisAnchor`.
    ///   - rhs: See `lhs`.
    /// - Returns: An `NSLayoutConstraint` object that defines an equal relationship between the attributes represented by the two layout anchors plus a constant offset.
    @discardableResult
    static func ~~<T: AxisAnchoring>(lhs: Self, rhs: T) -> NSLayoutConstraint where T.AnchorType == AnchorType {
        let constraint = lhs.constraint(equalTo: rhs.anchor, constant: rhs.constant)
        constraint.isActive = true
        return constraint
    }

    /// Returns a constraint that defines one item’s attribute as less than or equal to another item’s attribute plus an optional constant offset.
    ///
    /// - Parameters:
    ///   - lhs: A layout anchor from a `UIView`, `NSView`, or `UILayoutGuide` object. You must use a subclass of NSLayoutAnchor that matches the current anchor. For example, if you call this method on an `NSLayoutXAxisAnchor` object, this parameter must be another `NSLayoutXAxisAnchor`.
    ///   - rhs: See `lhs`.
    /// - Returns: An `NSLayoutConstraint` object that defines the attribute represented by this layout anchor as less than or equal to the attribute represented by the anchor parameter plus a constant offset.
    @discardableResult
    static func ≤≤<T: AxisAnchoring>(lhs: Self, rhs: T) -> NSLayoutConstraint where T.AnchorType == AnchorType {
        let constraint = lhs.constraint(lessThanOrEqualTo: rhs.anchor, constant: rhs.constant)
        constraint.isActive = true
        return constraint
    }

    /// Returns a constraint that defines one item’s attribute as greater than or equal to another item’s attribute plus a constant offset.
    ///
    /// - Parameters:
    ///   - lhs: A layout anchor from a `UIView`, `NSView`, or `UILayoutGuide` object. You must use a subclass of NSLayoutAnchor that matches the current anchor. For example, if you call this method on an `NSLayoutXAxisAnchor` object, this parameter must be another `NSLayoutXAxisAnchor`.
    ///   - rhs: See `lhs`.
    /// - Returns: An `NSLayoutConstraint` object that defines the attribute represented by this layout anchor as greater than or equal to the attribute represented by the anchor parameter plus a constant offset.
    @discardableResult
    static func ≥≥<T: AxisAnchoring>(lhs: Self, rhs: T) -> NSLayoutConstraint where T.AnchorType == AnchorType {
        let constraint = lhs.constraint(greaterThanOrEqualTo: rhs.anchor, constant: rhs.constant)
        constraint.isActive = true
        return constraint
    }
}
