//
//  TipJarViewController.swift
//
//  Created by Daniel Loewenherz on 10/20/17.
//  Copyright © 2017 Lionheart Software. All rights reserved.
//

import UIKit
import QuickTableView
import StoreKit

open class TipJarViewController<T>: BaseTableViewController, UITableViewDelegate, UITableViewDataSource, SKProductsRequestDelegate, SKPaymentTransactionObserver where T: TipJarConfiguration {
    var loading = true
    var purchased = false
    var products: [String: SKProduct]?
    var sectionContainer: Section.Container {
        return Section.Container(productsLoaded: products != nil, hasProducts: (products ?? [:]).count > 0, purchased: purchased)
    }
    
    @objc public init() {
        super.init()
    }
    
    @objc override init(style: UITableView.Style) {
        super.init(style: style)
    }
    
    enum Section: Int, QuickTableViewSectionWithConditions {
        struct Container {
            var productsLoaded: Bool
            var hasProducts: Bool
            var purchased: Bool
        }
        
        case restorePurchases
        case top
        case couldNotLoad
        case subscription
        case oneTime
        case loading
        case thankYou
        case manageSubscription
        case legal
        
        static func conditionalSections(for container: TipJarViewController.Section.Container) -> [(TipJarViewController.Section, Bool)] {
            return [
                (.top, !container.purchased || (container.productsLoaded && container.hasProducts)),
                (.couldNotLoad, container.productsLoaded && !container.hasProducts),
                (.subscription, container.productsLoaded && container.hasProducts && !container.purchased),
                (.oneTime, container.productsLoaded && container.hasProducts && !container.purchased),
                (.loading, !container.productsLoaded),
                (.thankYou, container.purchased),
                (.manageSubscription, container.purchased)
            ]
        }
    }
    
    enum LegalRow: Int, QuickTableViewRow {
        case termsOfUse
        case privacy
        
        static var title: String { return "Legal" }
        
        var title: String {
            switch self {
            case .termsOfUse: return "Terms of Use"
            case .privacy: return "Privacy Policy"
            }
        }
        
        var urlString: String {
            switch self {
            case .termsOfUse: return T.termsOfUseURLString
            case .privacy: return T.privacyPolicyURLString
            }
        }

        var url: URL? {
            return URL(string: urlString)
        }
    }
    
    public enum SubscriptionRow: Int, QuickTableViewRow, IAPRow {
        case monthly
        case yearly
        
        static var title: String { return T._subscriptionTitle }

        public var frequency: TipJarFrequency {
            switch self {
            case .monthly: return .monthly
            case .yearly: return .yearly
            }
        }

        public var productIdentifier: String {
            return T.subscriptionProductIdentifier(for: self)
        }
    }
    
    public enum OneTimeRow: Int, QuickTableViewRow, IAPRow {
        case small
        case medium
        case large
        case huge
        case massive

        static var title: String { return T._oneTimeTitle }
        
        public var frequency: TipJarFrequency { return .oneTime }

        public var productIdentifier: String {
            return T.oneTimeProductIdentifier(for: self)
        }
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        title = T._title
        
        let identifiers = SubscriptionRow.productIdentifiers + OneTimeRow.productIdentifiers
        let productsRequest = SKProductsRequest(productIdentifiers: Set(identifiers))
        productsRequest.delegate = self
        productsRequest.start()
        
        if let receiptURL = Bundle.main.appStoreReceiptURL,
            let data = try? Data(contentsOf: receiptURL),
            let url = T.receiptVerifierURL {
            let encodedData = data.base64EncodedData(options: [])
            var request = URLRequest(url: url)
            request.httpBody = encodedData
            request.httpMethod = "POST"
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data,
                    let object = try? JSONSerialization.jsonObject(with: data, options: []),
                    let json = object as? [String: Any],
                    let receiptInfo = json["latest_receipt_info"] as? [[String: Any]] else {
                        return
                }
                
                let now = Date()
                for info in receiptInfo {
                    guard let productID = info["product_id"] as? String,
                        let expiresDateMSString = info["expires_date_ms"] as? String,
                        SubscriptionRow.productIdentifiers.contains(productID) else {
                            continue
                    }
                    
                    let expiresDateMS = NSDecimalNumber(string: expiresDateMSString)
                    let date = Date(timeIntervalSince1970: expiresDateMS.doubleValue / 1000)
                    
                    guard date.compare(now) == .orderedAscending else {
                        self.purchased = true
                        break
                    }
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            task.resume()
        }
        
        tableView.registerClass(MultilineTableViewCell.self)
        tableView.registerClass(ActivityIndicatorTableViewCell.self)
        tableView.registerClass(TipJarTableViewCell.self)
        tableView.registerClass(QuickTableViewCellValue1.self)
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        SKPaymentQueue.default().remove(self)
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        SKPaymentQueue.default().add(self)
    }
    
    func addPaymentForIAP(row: IAPRow) {
        guard !loading else {
            return;
        }

        loading = true
        tableView.reloadData()

        guard let products = products,
            let product = products[row.productIdentifier] else {
                return
        }
        
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    @objc func monthlyTipButtonDidTouchUpInside() { addPaymentForIAP(row: SubscriptionRow.monthly) }
    @objc func yearlyTipButtonDidTouchUpInside() { addPaymentForIAP(row: SubscriptionRow.yearly) }
    @objc func smallTipButtonDidTouchUpInside() { addPaymentForIAP(row: OneTimeRow.small) }
    @objc func mediumTipButtonDidTouchUpInside() { addPaymentForIAP(row: OneTimeRow.medium) }
    @objc func largeTipButtonDidTouchUpInside() { addPaymentForIAP(row: OneTimeRow.large) }
    @objc func hugeTipButtonDidTouchUpInside() { addPaymentForIAP(row: OneTimeRow.huge) }
    @objc func massiveTipButtonDidTouchUpInside() { addPaymentForIAP(row: OneTimeRow.massive) }

    // MARK: - UITableViewDelegate
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var iapRow: IAPRow?
        switch Section(at: indexPath, container: sectionContainer) {
        case .restorePurchases:
            SKPaymentQueue.default().restoreCompletedTransactions()
            
        case .legal:
            let legalRow = LegalRow(at: indexPath)
            guard let url = legalRow.url else {
                print("Legal URL could not be parsed.")
                return
            }

            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            
        case .manageSubscription:
            let url = URL(string: "https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/manageSubscriptions")!
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            
        case .subscription:
            iapRow = SubscriptionRow(at: indexPath)
            
        case .oneTime:
            iapRow = OneTimeRow(at: indexPath)
            
        default: break
        }
        
        if let iapRow = iapRow {
            switch iapRow {
            case SubscriptionRow.monthly: monthlyTipButtonDidTouchUpInside()
            case SubscriptionRow.yearly: yearlyTipButtonDidTouchUpInside()
            case OneTimeRow.small: smallTipButtonDidTouchUpInside()
            case OneTimeRow.medium: mediumTipButtonDidTouchUpInside()
            case OneTimeRow.large: largeTipButtonDidTouchUpInside()
            case OneTimeRow.huge: hugeTipButtonDidTouchUpInside()
            case OneTimeRow.massive: massiveTipButtonDidTouchUpInside()
            default: break
            }
        }
    }

    // MARK: - UITableViewDataSource
    public func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count(for: sectionContainer)
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(at: section, container: sectionContainer) {
        case .restorePurchases: return 1
        case .top: return 1
        case .legal: return LegalRow.count
        case .couldNotLoad: return 1
        case .loading: return 1
        case .subscription: return SubscriptionRow.count
        case .oneTime: return OneTimeRow.count
        case .thankYou: return 1
        case .manageSubscription: return 1
        }
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(at: section, container: sectionContainer) {
        case .restorePurchases: return nil
        case .top: return nil
        case .legal: return LegalRow.title
        case .couldNotLoad: return nil
        case .loading: return nil
        case .subscription: return SubscriptionRow.title
        case .oneTime: return OneTimeRow.title
        case .thankYou: return nil
        case .manageSubscription: return nil
        }
    }
    
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch Section(at: section, container: sectionContainer) {
        case .restorePurchases: return nil
        case .top: return nil
        case .legal: return nil
        case .couldNotLoad: return nil
        case .loading: return nil
        case .subscription: return nil
        case .oneTime: return """
            Payment will be charged to your iTunes account at confirmation of purchase.
            
            Your subscription will automatically renew unless auto-renew is turned off at least 24-hours before the end of the current subscription period.
            
            Your account will be charged for renewal within 24-hours prior to the end of the current subscription period. Automatic renewals will cost the same price you were originally charged for the subscription.
            
            You can manage your subscriptions and turn off auto-renewal by going to your Account Settings on the App Store after purchase.
            """
        case .thankYou: return nil
        case .manageSubscription: return nil
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row: IAPRow
        switch Section(at: indexPath, container: sectionContainer) {
        case .restorePurchases:
            let cell = tableView.dequeueReusableCell(for: indexPath) as QuickTableViewCellValue1
            cell.textLabel?.text = "Restore Purchases"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = TipJarButton.blue
            return cell

        case .top:
            let cell = tableView.dequeueReusableCell(for: indexPath) as MultilineTableViewCell
            cell.textLabel?.text = T.topHeader
            cell.detailTextLabel?.text = T.topDescription
            return cell
            
        case .legal:
            let legalRow = LegalRow(at: indexPath)
            let cell = tableView.dequeueReusableCell(for: indexPath) as QuickTableViewCellValue1
            cell.textLabel?.text = legalRow.title
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.textColor = TipJarButton.blue
            return cell
            
        case .couldNotLoad:
            let cell = tableView.dequeueReusableCell(for: indexPath) as MultilineTableViewCell
            cell.textLabel?.text = "Oh no!"
            cell.detailTextLabel?.text = "There was an error loading In-App Purchase information."
            return cell
            
        case .thankYou:
            let cell = tableView.dequeueReusableCell(for: indexPath) as MultilineTableViewCell
            cell.textLabel?.text = "Thank You!"
            cell.detailTextLabel?.text = "Your generous tip goes such a long way. Thank you so much for your support!"
            return cell
            
        case .manageSubscription:
            let cell = tableView.dequeueReusableCell(for: indexPath) as QuickTableViewCellValue1
            cell.textLabel?.text = "Manage Subscriptions"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = TipJarButton.blue
            return cell
            
        case .loading:
            return tableView.dequeueReusableCell(for: indexPath) as ActivityIndicatorTableViewCell
            
        case .subscription:
            row = SubscriptionRow(at: indexPath)
            
        case .oneTime:
            row = OneTimeRow(at: indexPath)
        }
        
        let cell = tableView.dequeueReusableCell(for: indexPath) as TipJarTableViewCell
        if let product = products?[row.productIdentifier] {
            let selector: Selector
            switch row {
            case SubscriptionRow.monthly: selector = #selector(monthlyTipButtonDidTouchUpInside)
            case SubscriptionRow.yearly: selector = #selector(yearlyTipButtonDidTouchUpInside)
            case OneTimeRow.small: selector = #selector(smallTipButtonDidTouchUpInside)
            case OneTimeRow.medium: selector = #selector(mediumTipButtonDidTouchUpInside)
            case OneTimeRow.large: selector = #selector(largeTipButtonDidTouchUpInside)
            case OneTimeRow.huge: selector = #selector(hugeTipButtonDidTouchUpInside)
            case OneTimeRow.massive: selector = #selector(massiveTipButtonDidTouchUpInside)
            default: return cell
            }
            
            if loading {
                cell.tipJarButton.removeTarget(nil, action: nil, for: .allEvents)
                cell.tipJarButton.isEnabled = false
            } else {
                cell.tipJarButton.addTarget(self, action: selector, for: .touchUpInside)
                cell.tipJarButton.isEnabled = true
            }
            
            cell.textLabel?.text = product.localizedTitle
            cell.detailTextLabel?.text = product.localizedDescription
            
            let currencyFormatter: NumberFormatter = {
                let formatter = NumberFormatter()
                formatter.numberStyle = .currency
                formatter.locale = product.priceLocale
                formatter.maximumFractionDigits = 2
                return formatter
            }()
            
            if let formattedAmount = currencyFormatter.string(from: product.price) {
                cell.tipJarButton.setAmount(amount: formattedAmount, frequency: row.frequency)
            }
        }
        return cell
    }

    // MARK: - SKProductsRequestDelegate
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        products = [:]
        for product in response.products {
            products?[product.productIdentifier] = product
        }
        
        loading = false

        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }

    // MARK: - SKPaymentTransactionObserver
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        loading = false
        print(Date())
        tableView.reloadData()

        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased, .restored:
                purchased = true

                queue.finishTransaction(transaction)

                tableView.reloadData()

            case .deferred:
                queue.finishTransaction(transaction)
                break

            case .failed:
                queue.finishTransaction(transaction)
                guard let error = transaction.error as? SKError else {
                    return
                }

                let message: String
                switch error {
                case SKError.unknown:
                    // This error occurs if running on the simulator.
                    message = error.localizedDescription

                case SKError.clientInvalid:
                    message = "This client is unauthorized to make In-App Purchases."

                default:
                    message = error.localizedDescription
                }

                let alert = UIAlertController(title: "Purchase Error", message: message, preferredStyle: .alert)
                alert.addAction(title: "OK", style: .default, handler: nil)
                present(alert, animated: true)

            case .purchasing:
                break

            @unknown default:
                fatalError()
            }
        }
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        return true
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
