import Foundation
import AppsFlyerLib

/// Centralized analytics manager for AppsFlyer event tracking.
/// All events use standard AppsFlyer event names for automatic mapping to TikTok/Apple.
final class AnalyticsManager {
    
    static let shared = AnalyticsManager()
    
    private init() {}
    
    // MARK: - Subscription & Revenue Events (Critical)
    
    /// Trigger when user starts a free trial
    /// - Parameters:
    ///   - trialType: The type of trial (e.g., "weekly", "monthly", "yearly")
    ///   - price: The price after trial ends
    ///   - currency: Currency code (default: USD)
    func trackStartTrial(trialType: String, price: Double? = nil, currency: String = "USD") {
        var eventValues: [String: Any] = [
            AFEventParamContentType: trialType
        ]
        
        if let price = price {
            eventValues[AFEventParamPrice] = price
            eventValues[AFEventParamCurrency] = currency
        }
        
        AppsFlyerLib.shared().logEvent(AFEventStartTrial, withValues: eventValues)
        print("📊 Analytics: af_start_trial - \(eventValues)")
    }
    
    /// Trigger when user converts to paid subscription
    /// - Parameters:
    ///   - subscriptionType: The subscription plan (e.g., "weekly", "monthly", "yearly")
    ///   - revenue: The subscription revenue amount
    ///   - currency: Currency code (default: USD)
    ///   - productId: The product identifier
    func trackSubscribe(subscriptionType: String, revenue: Double, currency: String = "USD", productId: String? = nil) {
        var eventValues: [String: Any] = [
            AFEventParamContentType: subscriptionType,
            AFEventParamRevenue: revenue,
            AFEventParamCurrency: currency
        ]
        
        if let productId = productId {
            eventValues[AFEventParamContentId] = productId
        }
        
        AppsFlyerLib.shared().logEvent(AFEventSubscribe, withValues: eventValues)
        print("📊 Analytics: af_subscribe - \(eventValues)")
    }
    
    /// Backup purchase event - fire alongside subscribe for safety
    /// - Parameters:
    ///   - productId: The product identifier
    ///   - revenue: The purchase revenue amount
    ///   - currency: Currency code (default: USD)
    ///   - quantity: Number of items purchased (default: 1)
    func trackPurchase(productId: String, revenue: Double, currency: String = "USD", quantity: Int = 1) {
        let eventValues: [String: Any] = [
            AFEventParamContentId: productId,
            AFEventParamRevenue: revenue,
            AFEventParamCurrency: currency,
            AFEventParamQuantity: quantity
        ]
        
        AppsFlyerLib.shared().logEvent(AFEventPurchase, withValues: eventValues)
        print("📊 Analytics: af_purchase - \(eventValues)")
    }
    
    /// Trigger when user views the paywall/pricing screen
    /// - Parameters:
    ///   - paywallId: Identifier for the paywall placement
    ///   - source: Where the paywall was triggered from
    func trackInitiatedCheckout(paywallId: String, source: String? = nil) {
        var eventValues: [String: Any] = [
            AFEventParamContentId: paywallId
        ]
        
        if let source = source {
            eventValues[AFEventParamContentType] = source
        }
        
        AppsFlyerLib.shared().logEvent(AFEventInitiatedCheckout, withValues: eventValues)
        print("📊 Analytics: af_initiated_checkout - \(eventValues)")
    }
    
    // MARK: - Onboarding Funnel Events
    
    /// Trigger after signup/login is done (first time registration)
    /// - Parameters:
    ///   - method: Registration method (e.g., "email", "apple", "google", "onboarding")
    ///   - userId: Optional user identifier
    func trackCompleteRegistration(method: String = "onboarding", userId: String? = nil) {
        var eventValues: [String: Any] = [
            AFEventParamRegistrationMethod: method
        ]
        
        if let userId = userId {
            eventValues[AFEventParamCustomerUserId] = userId
        }
        
        AppsFlyerLib.shared().logEvent(AFEventCompleteRegistration, withValues: eventValues)
        print("📊 Analytics: af_complete_registration - \(eventValues)")
    }
    
    /// Trigger when user finishes the intro quiz/onboarding flow
    /// - Parameters:
    ///   - tutorialId: Identifier for the tutorial/quiz completed
    ///   - success: Whether the tutorial was completed successfully
    func trackTutorialCompletion(tutorialId: String = "intro_quiz", success: Bool = true) {
        let eventValues: [String: Any] = [
            AFEventParamTutorialId: tutorialId,
            AFEventParamSuccess: success ? "true" : "false"
        ]
        
        AppsFlyerLib.shared().logEvent(AFEventTutorial_completion, withValues: eventValues)
        print("📊 Analytics: af_tutorial_completion - \(eventValues)")
    }
    
    /// Trigger on subsequent app opens (returning user login)
    /// - Parameter method: Login method (e.g., "app_open", "returning_user")
    func trackLogin(method: String = "app_open") {
        let eventValues: [String: Any] = [
            AFEventParamRegistrationMethod: method
        ]
        
        AppsFlyerLib.shared().logEvent(AFEventLogin, withValues: eventValues)
        print("📊 Analytics: af_login - \(eventValues)")
    }
    
    // MARK: - Engagement Events (Product Usage)
    
    /// Trigger when user opens a specific tool/feature
    /// - Parameters:
    ///   - contentId: Identifier for the content/tool (e.g., "panic_button", "breathe", "roast_me")
    ///   - contentType: Type of content (e.g., "tool", "feature", "screen")
    func trackContentView(contentId: String, contentType: String = "tool") {
        let eventValues: [String: Any] = [
            AFEventParamContentId: contentId,
            AFEventParamContentType: contentType
        ]
        
        AppsFlyerLib.shared().logEvent(AFEventContentView, withValues: eventValues)
        print("📊 Analytics: af_content_view - \(eventValues)")
    }
    
    /// Trigger when user hits a streak milestone
    /// - Parameters:
    ///   - level: The streak level/milestone achieved
    ///   - score: The streak day count
    func trackLevelAchieved(level: String, score: Int) {
        let eventValues: [String: Any] = [
            AFEventParamLevel: level,
            AFEventParamScore: String(score)
        ]
        
        AppsFlyerLib.shared().logEvent(AFEventLevelAchieved, withValues: eventValues)
        print("📊 Analytics: af_level_achieved - \(eventValues)")
    }
    
    /// Trigger every time user taps the Panic Button (identifies power users)
    /// - Parameters:
    ///   - featureName: Name of the feature used (e.g., "panic_button", "breathe", "power_action")
    ///   - details: Additional details about the feature usage
    func trackFeatureUse(featureName: String, details: String? = nil) {
        var eventValues: [String: Any] = [
            AFEventParamContentId: featureName,
            AFEventParamDescription: featureName
        ]
        
        if let details = details {
            eventValues[AFEventParam1] = details
        }
        
        // Using custom event name as af_feature_use is not a predefined constant
        AppsFlyerLib.shared().logEvent("af_feature_use", withValues: eventValues)
        print("📊 Analytics: af_feature_use - \(eventValues)")
    }
    
    // MARK: - Convenience Methods
    
    /// Track panic button tap specifically (convenience method)
    func trackPanicButtonTap() {
        trackFeatureUse(featureName: "panic_button", details: "sos_mode_opened")
        trackContentView(contentId: "panic_button", contentType: "sos_tool")
    }
    
    /// Track breathe/meditate feature usage
    func trackBreatheTap() {
        trackFeatureUse(featureName: "breathe", details: "meditation_opened")
        trackContentView(contentId: "breathe", contentType: "wellness_tool")
    }
    
    /// Track roast me feature usage
    func trackRoastMeTap() {
        trackFeatureUse(featureName: "roast_me", details: "roast_opened")
        trackContentView(contentId: "roast_me", contentType: "motivation_tool")
    }
    
    /// Track power actions feature usage
    func trackPowerActionsTap() {
        trackFeatureUse(featureName: "power_actions", details: "power_actions_opened")
        trackContentView(contentId: "power_actions", contentType: "engagement_tool")
    }
    
    /// Track streak milestone achievement
    /// - Parameters:
    ///   - streakDays: Current streak day count
    ///   - levelName: Name of the level (e.g., "Emergency", "Withdrawal", etc.)
    func trackStreakMilestone(streakDays: Int, levelName: String) {
        trackLevelAchieved(level: levelName, score: streakDays)
    }
    
    /// Track paywall view from specific placement
    /// - Parameter placement: The Superwall placement identifier
    func trackPaywallView(placement: String) {
        trackInitiatedCheckout(paywallId: placement, source: "superwall")
    }
    
    /// Track successful subscription with both subscribe and purchase events
    /// - Parameters:
    ///   - subscriptionType: Type of subscription
    ///   - revenue: Revenue amount
    ///   - currency: Currency code
    ///   - productId: Product identifier
    ///   - isTrial: Whether this is a trial start
    func trackSuccessfulSubscription(
        subscriptionType: String,
        revenue: Double,
        currency: String = "USD",
        productId: String,
        isTrial: Bool = false
    ) {
        if isTrial {
            trackStartTrial(trialType: subscriptionType, price: revenue, currency: currency)
        } else {
            trackSubscribe(subscriptionType: subscriptionType, revenue: revenue, currency: currency, productId: productId)
            // Fire purchase as backup
            trackPurchase(productId: productId, revenue: revenue, currency: currency)
        }
    }
}
