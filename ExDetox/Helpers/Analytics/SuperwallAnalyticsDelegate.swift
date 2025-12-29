import Foundation
import SuperwallKit
import AppsFlyerLib

/// Superwall delegate to track paywall and subscription events for AppsFlyer analytics.
final class SuperwallAnalyticsDelegate: SuperwallDelegate {
    
    static let shared = SuperwallAnalyticsDelegate()
    
    private init() {}
    
    // MARK: - SuperwallDelegate Methods
    
    /// Main event handler for all Superwall events using SuperwallEvent enum
    func handleSuperwallEvent(withInfo eventInfo: SuperwallEventInfo) {
        switch eventInfo.event {
            
        // MARK: - af_initiated_checkout (Paywall View)
        case .paywallOpen(let paywallInfo):
            let placement = paywallInfo.presentedByPlacementWithName ?? "unknown"
            AnalyticsManager.shared.trackInitiatedCheckout(
                paywallId: paywallInfo.identifier,
                source: placement
            )
            print("📊 Superwall: Paywall opened - \(paywallInfo.identifier), placement: \(placement)")
            
        // MARK: - af_subscribe + af_purchase (Transaction Complete)
        case .transactionComplete(_, let product, let type, _):
            let productId = product.productIdentifier
            let price = NSDecimalNumber(decimal: product.price).doubleValue
            let currency = product.currencyCode ?? "USD"
            let subscriptionType = determineSubscriptionType(from: productId)
            
            // Fire af_subscribe
            AnalyticsManager.shared.trackSubscribe(
                subscriptionType: subscriptionType,
                revenue: price,
                currency: currency,
                productId: productId
            )
            
            // Fire af_purchase as backup
            AnalyticsManager.shared.trackPurchase(
                productId: productId,
                revenue: price,
                currency: currency
            )
            print("📊 Superwall: Transaction complete - \(productId), type: \(type)")
            
        // MARK: - af_start_trial (Free Trial Start)
        case .freeTrialStart(let product, _):
            let productId = product.productIdentifier
            let price = NSDecimalNumber(decimal: product.price).doubleValue
            let currency = product.currencyCode ?? "USD"
            let subscriptionType = determineSubscriptionType(from: productId)
            
            AnalyticsManager.shared.trackStartTrial(
                trialType: subscriptionType,
                price: price,
                currency: currency
            )
            print("📊 Superwall: Free trial started - \(productId)")
            
        // MARK: - Subscription Start (also fires af_subscribe)
        case .subscriptionStart(let product, _):
            let productId = product.productIdentifier
            let price = NSDecimalNumber(decimal: product.price).doubleValue
            let currency = product.currencyCode ?? "USD"
            let subscriptionType = determineSubscriptionType(from: productId)
            
            AnalyticsManager.shared.trackSubscribe(
                subscriptionType: subscriptionType,
                revenue: price,
                currency: currency,
                productId: productId
            )
            print("📊 Superwall: Subscription started - \(productId)")
            
        // MARK: - Other Events (Logging)
        case .paywallClose(let paywallInfo):
            print("📊 Superwall: Paywall closed - \(paywallInfo.identifier)")
            
        case .transactionStart(let product, let paywallInfo):
            print(paywallInfo.identifier)
            print("📊 Superwall: Transaction started - \(product.productIdentifier)")
            
        case .transactionFail(let error, _):
            print("📊 Superwall: Transaction failed - \(error.localizedDescription)")
            
        case .transactionAbandon(let product, _):
            print("📊 Superwall: Transaction abandoned - \(product.productIdentifier)")
            
        case .transactionRestore(let restoreType, _):
            print("📊 Superwall: Transaction restored - \(restoreType)")
            
        case .subscriptionStatusDidChange:
            print("📊 Superwall: Subscription status changed")
            
        default:
            break
        }
    }
    
    // MARK: - Helper Methods
    
    private func determineSubscriptionType(from productId: String) -> String {
        let lowercased = productId.lowercased()
        
        if lowercased.contains("weekly") || lowercased.contains("week") {
            return "weekly"
        } else if lowercased.contains("monthly") || lowercased.contains("month") {
            return "monthly"
        } else if lowercased.contains("yearly") || lowercased.contains("year") || lowercased.contains("annual") {
            return "yearly"
        } else if lowercased.contains("lifetime") {
            return "lifetime"
        } else {
            return "subscription"
        }
    }
}
