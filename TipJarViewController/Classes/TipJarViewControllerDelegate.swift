//
//  TipJarViewControllerDelegate.swift
//  TipJarViewController
//
//  Created by Dan Loewenherz on 5/6/18.
//

import UIKit
import QuickTableView

public protocol TipJarConfiguration {
    static var topHeader: String { get }
    static var topDescription: String { get }
    static var termsOfUseURLString: String { get }
    static var privacyPolicyURLString: String { get }

    static func subscriptionProductIdentifier(for subscription: TipJarViewController<Self>.SubscriptionRow) -> String
    static func oneTimeProductIdentifier(for subscription: TipJarViewController<Self>.OneTimeRow) -> String
}

public protocol TipJarOptionalConfiguration {
    static var title: String { get }
    static var oneTimeTipsTitle: String { get }
    static var subscriptionTipsTitle: String { get }

    static var receiptVerifierURLString: String { get }
}

public extension TipJarConfiguration {
    static var options: TipJarOptionalConfiguration.Type? {
        return self as? TipJarOptionalConfiguration.Type
    }

    static var receiptVerifierURL: URL? {
        guard let string = options?.receiptVerifierURLString else {
            return nil
        }

        return URL(string: string)
    }

    static var _title: String { return options?.title ?? "Tip Jar" }
    static var _oneTimeTitle: String { return options?.oneTimeTipsTitle ?? "One-Time Tips" }
    static var _subscriptionTitle: String { return options?.subscriptionTipsTitle ?? "Ongoing Tips ❤️" }
}
