import Foundation
import AppsFlyerLib
import FirebaseAnalytics

/// Centralized analytics manager for AppsFlyer + Firebase event tracking.
/// All events are sent to both platforms for comprehensive analytics.
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
        
        // Firebase
        FirebaseAnalyticsManager.shared.trackSubscriptionStart(
            productId: eventValues[AFEventParamContentId] as? String ?? trialType,
            price: price ?? 0,
            currency: currency,
            type: trialType,
            isTrial: true
        )
        
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
        
        // Firebase
        FirebaseAnalyticsManager.shared.trackSubscriptionStart(
            productId: productId ?? subscriptionType,
            price: revenue,
            currency: currency,
            type: subscriptionType,
            isTrial: false
        )
        
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
        
        // Firebase
        FirebaseAnalyticsManager.shared.trackPurchaseComplete(
            productId: productId,
            price: revenue,
            currency: currency
        )
        
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
        
        // Firebase
        FirebaseAnalyticsManager.shared.trackPaywallView(
            paywallId: paywallId,
            source: source ?? "unknown"
        )
        
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
        
        // Firebase
        FirebaseAnalyticsManager.shared.trackOnboardingComplete()
        FirebaseAnalyticsManager.shared.setOnboardingComplete(true)
        
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
        
        // Firebase
        FirebaseAnalyticsManager.shared.trackOnboardingQuizComplete(exNameSet: true, exGender: "")
        
        print("📊 Analytics: af_tutorial_completion - \(eventValues)")
    }
    
    /// Trigger on subsequent app opens (returning user login)
    /// - Parameter method: Login method (e.g., "app_open", "returning_user")
    func trackLogin(method: String = "app_open") {
        let eventValues: [String: Any] = [
            AFEventParamRegistrationMethod: method
        ]
        
        AppsFlyerLib.shared().logEvent(AFEventLogin, withValues: eventValues)
        
        // Firebase
        FirebaseAnalyticsManager.shared.trackAppOpen(isReturningUser: true)
        
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
        
        // Firebase - handled by specific feature tracking methods
        
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
        
        // Firebase
        FirebaseAnalyticsManager.shared.trackStreakMilestone(days: score, level: level)
        FirebaseAnalyticsManager.shared.setUserLevel(level)
        FirebaseAnalyticsManager.shared.setUserStreakDays(score)
        
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
        
        // Firebase - specific feature events handled by convenience methods
        
        print("📊 Analytics: af_feature_use - \(eventValues)")
    }
    
    // MARK: - Convenience Methods
    
    /// Track panic button tap specifically (convenience method)
    func trackPanicButtonTap() {
        trackFeatureUse(featureName: "panic_button", details: "sos_mode_opened")
        trackContentView(contentId: "panic_button", contentType: "sos_tool")
        
        // Firebase
        FirebaseAnalyticsManager.shared.trackPanicButtonTap()
    }
    
    /// Track breathe/meditate feature usage
    func trackBreatheTap() {
        trackFeatureUse(featureName: "breathe", details: "meditation_opened")
        trackContentView(contentId: "breathe", contentType: "wellness_tool")
        
        // Firebase
        FirebaseAnalyticsManager.shared.trackBreatheOpen()
    }
    
    /// Track roast me feature usage
    func trackRoastMeTap() {
        trackFeatureUse(featureName: "roast_me", details: "roast_opened")
        trackContentView(contentId: "roast_me", contentType: "motivation_tool")
        
        // Firebase
        FirebaseAnalyticsManager.shared.trackRoastMeOpen()
    }
    
    /// Track power actions feature usage
    func trackPowerActionsTap() {
        trackFeatureUse(featureName: "power_actions", details: "power_actions_opened")
        trackContentView(contentId: "power_actions", contentType: "engagement_tool")
        
        // Firebase
        FirebaseAnalyticsManager.shared.trackPowerActionsOpen()
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
        // Firebase tracking handled in trackInitiatedCheckout
    }
    
    // MARK: - Additional Firebase-Specific Tracking
    
    /// Track onboarding step progression
    func trackOnboardingStep(step: Int, name: String) {
        FirebaseAnalyticsManager.shared.trackOnboardingStep(step: step, name: name)
    }
    
    /// Track tab switch in main view
    func trackTabSwitch(from previousTab: String?, to newTab: String) {
        FirebaseAnalyticsManager.shared.trackTabSwitch(from: previousTab, to: newTab)
    }
    
    /// Track AI agent message sent
    func trackAiMessageSent(messageLength: Int) {
        trackFeatureUse(featureName: "ai_agent", details: "message_sent")
        FirebaseAnalyticsManager.shared.trackAiMessageSent(messageLength: messageLength)
    }
    
    /// Track AI agent opened
    func trackAiAgentOpen() {
        trackContentView(contentId: "ai_agent", contentType: "chat_tool")
        FirebaseAnalyticsManager.shared.trackAiAgentOpen()
    }
    
    /// Track My Why opened
    func trackMyWhyOpen(itemCount: Int) {
        trackContentView(contentId: "my_why", contentType: "motivation_screen")
        FirebaseAnalyticsManager.shared.trackMyWhyOpen(itemCount: itemCount)
    }
    
    /// Track Why item added
    func trackWhyItemAdd(hasImage: Bool) {
        trackFeatureUse(featureName: "my_why", details: "item_added")
        FirebaseAnalyticsManager.shared.trackWhyItemAdd(hasImage: hasImage)
    }
    
    /// Track Learning opened
    func trackLearningOpen(completedCount: Int, totalCount: Int) {
        trackContentView(contentId: "learning", contentType: "education_screen")
        FirebaseAnalyticsManager.shared.trackLearningOpen(completedCount: completedCount, totalCount: totalCount)
    }
    
    /// Track lesson started
    func trackLessonStart(lessonId: String, sectionId: String) {
        trackFeatureUse(featureName: "learning", details: "lesson_started")
        FirebaseAnalyticsManager.shared.trackLessonStart(lessonId: lessonId, sectionId: sectionId)
    }
    
    /// Track lesson completed
    func trackLessonComplete(lessonId: String, sectionId: String) {
        trackFeatureUse(featureName: "learning", details: "lesson_completed")
        FirebaseAnalyticsManager.shared.trackLessonComplete(lessonId: lessonId, sectionId: sectionId)
    }
    
    /// Track article opened
    func trackArticleOpen(articleId: String, articleTitle: String) {
        trackContentView(contentId: articleId, contentType: "article")
        FirebaseAnalyticsManager.shared.trackArticleOpen(articleId: articleId, articleTitle: articleTitle)
    }
    
    /// Track article completed
    func trackArticleComplete(articleId: String) {
        trackFeatureUse(featureName: "learning", details: "article_completed")
        FirebaseAnalyticsManager.shared.trackArticleComplete(articleId: articleId)
    }
    
    /// Track Analytics view opened
    func trackAnalyticsViewOpen(streakDays: Int, level: String) {
        trackContentView(contentId: "analytics", contentType: "progress_screen")
        FirebaseAnalyticsManager.shared.trackAnalyticsViewOpen(streakDays: streakDays, level: level)
    }
    
    /// Track daily check-in
    func trackDailyCheckIn(moodScore: Int, urgeScore: Int, hasNote: Bool) {
        trackFeatureUse(featureName: "check_in", details: "daily_check_in")
        FirebaseAnalyticsManager.shared.trackDailyCheckIn(moodScore: moodScore, urgeScore: urgeScore, hasNote: hasNote)
    }
    
    /// Track relapse
    func trackRelapse(previousStreak: Int) {
        trackFeatureUse(featureName: "relapse", details: "streak_reset")
        FirebaseAnalyticsManager.shared.trackRelapse(previousStreak: previousStreak)
    }
    
    /// Track settings opened
    func trackSettingsOpen() {
        trackContentView(contentId: "settings", contentType: "settings_screen")
        FirebaseAnalyticsManager.shared.trackSettingsOpen()
    }
    
    /// Track breathing session start
    func trackBreathingSessionStart() {
        trackFeatureUse(featureName: "breathe", details: "session_started")
        FirebaseAnalyticsManager.shared.trackBreathingSessionStart()
    }
    
    /// Track breathing session complete
    func trackBreathingSessionComplete(durationSeconds: Int) {
        trackFeatureUse(featureName: "breathe", details: "session_completed")
        FirebaseAnalyticsManager.shared.trackBreathingSessionComplete(durationSeconds: durationSeconds)
    }
    
    /// Track roast generated
    func trackRoastGenerated() {
        trackFeatureUse(featureName: "roast_me", details: "roast_generated")
        FirebaseAnalyticsManager.shared.trackRoastGenerated()
    }
    
    /// Track power action tap
    func trackPowerActionTap(actionName: String) {
        trackFeatureUse(featureName: "power_actions", details: actionName)
        FirebaseAnalyticsManager.shared.trackPowerActionTap(actionName: actionName)
    }
    
    /// Track power action complete
    func trackPowerActionComplete(actionName: String) {
        trackFeatureUse(featureName: "power_actions", details: "\(actionName)_completed")
        FirebaseAnalyticsManager.shared.trackPowerActionComplete(actionName: actionName)
    }
    
    /// Track level up
    func trackLevelUp(from previousLevel: String, to newLevel: String, streakDays: Int) {
        trackLevelAchieved(level: newLevel, score: streakDays)
        FirebaseAnalyticsManager.shared.trackLevelUp(from: previousLevel, to: newLevel, streakDays: streakDays)
    }
    
    /// Track badge earned
    func trackBadgeEarned(badgeName: String) {
        trackFeatureUse(featureName: "badge", details: badgeName)
        FirebaseAnalyticsManager.shared.trackBadgeEarned(badgeName: badgeName)
    }
    
    /// Track notification toggle
    func trackNotificationToggle(enabled: Bool, type: String) {
        FirebaseAnalyticsManager.shared.trackNotificationToggle(enabled: enabled, type: type)
    }
    
    /// Track start fresh (reset all data)
    func trackStartFresh() {
        trackFeatureUse(featureName: "settings", details: "start_fresh")
        FirebaseAnalyticsManager.shared.trackStartFresh()
    }
    
    /// Track rate app
    func trackRateApp(source: String) {
        trackFeatureUse(featureName: "rate_app", details: source)
        FirebaseAnalyticsManager.shared.trackRateApp(source: source)
    }
    
    /// Track share app
    func trackShareApp(method: String) {
        trackFeatureUse(featureName: "share_app", details: method)
        FirebaseAnalyticsManager.shared.trackShareApp(method: method)
    }
    
    /// Track Ex Quiz opened
    func trackExQuizOpen() {
        trackContentView(contentId: "ex_quiz", contentType: "quiz_tool")
        FirebaseAnalyticsManager.shared.trackExQuizOpen()
    }
    
    /// Track Ex Quiz complete
    func trackExQuizComplete(score: Int) {
        trackFeatureUse(featureName: "ex_quiz", details: "completed")
        FirebaseAnalyticsManager.shared.trackExQuizComplete(score: score)
    }
    
    /// Track panic view action
    func trackPanicViewAction(action: String) {
        trackFeatureUse(featureName: "panic", details: action)
        FirebaseAnalyticsManager.shared.trackPanicViewAction(action: action)
    }
    
    /// Track burn text feature
    func trackBurnTextStart() {
        trackFeatureUse(featureName: "burn_text", details: "started")
        FirebaseAnalyticsManager.shared.trackBurnTextStart()
    }
    
    func trackBurnTextComplete() {
        trackFeatureUse(featureName: "burn_text", details: "completed")
        FirebaseAnalyticsManager.shared.trackBurnTextComplete()
    }
    
    /// Track AI limit reached
    func trackAiLimitReached() {
        trackFeatureUse(featureName: "ai_agent", details: "limit_reached")
        FirebaseAnalyticsManager.shared.trackAiLimitReached()
    }
    
    /// Track onboarding notification response
    func trackOnboardingNotificationResponse(enabled: Bool) {
        FirebaseAnalyticsManager.shared.trackOnboardingNotificationResponse(enabled: enabled)
    }
    
    /// Track onboarding rating
    func trackOnboardingRating(rating: Int) {
        FirebaseAnalyticsManager.shared.trackOnboardingRating(rating: rating)
    }
    
    /// Track screen view
    func trackScreenView(_ screen: FirebaseAnalyticsManager.ScreenName) {
        FirebaseAnalyticsManager.shared.logScreenView(screen)
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
