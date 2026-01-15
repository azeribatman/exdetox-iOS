import Foundation
import FirebaseAnalytics

/// Centralized Firebase Analytics manager for comprehensive event tracking.
/// Tracks all user interactions, screen views, onboarding funnel, and engagement metrics.
final class FirebaseAnalyticsManager {
    
    static let shared = FirebaseAnalyticsManager()
    
    private init() {}
    
    // MARK: - Event Names
    
    enum EventName: String {
        // App Lifecycle
        case appOpen = "app_open"
        case appBackground = "app_background"
        case sessionStart = "session_start"
        
        // Onboarding Funnel
        case onboardingStart = "onboarding_start"
        case onboardingStep = "onboarding_step"
        case onboardingQuizStart = "onboarding_quiz_start"
        case onboardingQuizAnswer = "onboarding_quiz_answer"
        case onboardingQuizComplete = "onboarding_quiz_complete"
        case onboardingNotificationPrompt = "onboarding_notification_prompt"
        case onboardingNotificationResponse = "onboarding_notification_response"
        case onboardingRating = "onboarding_rating"
        case onboardingComplete = "onboarding_complete"
        
        // Screen Views
        case screenView = "screen_view"
        case tabSwitch = "tab_switch"
        
        // Core Features - Panic/SOS
        case panicButtonTap = "panic_button_tap"
        case panicViewOpen = "panic_view_open"
        case panicViewAction = "panic_view_action"
        
        // Core Features - Breathe/Meditate
        case breatheOpen = "breathe_open"
        case breathingSessionStart = "breathing_session_start"
        case breathingSessionComplete = "breathing_session_complete"
        case burnTextStart = "burn_text_start"
        case burnTextComplete = "burn_text_complete"
        
        // Core Features - Roast Me
        case roastMeOpen = "roast_me_open"
        case roastGenerated = "roast_generated"
        case roastShared = "roast_shared"
        
        // Core Features - Power Actions
        case powerActionsOpen = "power_actions_open"
        case powerActionTap = "power_action_tap"
        case powerActionComplete = "power_action_complete"
        
        // AI Agent
        case aiAgentOpen = "ai_agent_open"
        case aiMessageSent = "ai_message_sent"
        case aiResponseReceived = "ai_response_received"
        case aiConversationLength = "ai_conversation_length"
        case aiLimitReached = "ai_limit_reached"
        
        // My Why
        case myWhyOpen = "my_why_open"
        case whyItemAdd = "why_item_add"
        case whyItemDelete = "why_item_delete"
        case whyItemView = "why_item_view"
        
        // Learning
        case learningOpen = "learning_open"
        case lessonStart = "lesson_start"
        case lessonComplete = "lesson_complete"
        case articleOpen = "article_open"
        case articleComplete = "article_complete"
        case sectionExpand = "section_expand"
        
        // Analytics/Progress
        case analyticsViewOpen = "analytics_view_open"
        case levelProgressView = "level_progress_view"
        case badgesView = "badges_view"
        case allLevelsView = "all_levels_view"
        
        // Streak & Progress
        case streakMilestone = "streak_milestone"
        case levelUp = "level_up"
        case badgeEarned = "badge_earned"
        case dailyCheckIn = "daily_check_in"
        case relapse = "relapse"
        case streakReset = "streak_reset"
        
        // Settings
        case settingsOpen = "settings_open"
        case notificationToggle = "notification_toggle"
        case startFresh = "start_fresh"
        case rateApp = "rate_app"
        case shareApp = "share_app"
        case contactSupport = "contact_support"
        case privacyPolicyView = "privacy_policy_view"
        case termsView = "terms_view"
        
        // Subscription/Paywall
        case paywallView = "paywall_view"
        case paywallDismiss = "paywall_dismiss"
        case subscriptionStart = "subscription_start"
        case trialStart = "trial_start"
        case purchaseComplete = "purchase_complete"
        case purchaseFailed = "purchase_failed"
        case restorePurchase = "restore_purchase"
        
        // Engagement
        case quoteView = "quote_view"
        case quoteSaved = "quote_saved"
        case exQuizOpen = "ex_quiz_open"
        case exQuizComplete = "ex_quiz_complete"
        case shareContent = "share_content"
    }
    
    // MARK: - Parameter Keys
    
    enum ParamKey: String {
        case screenName = "screen_name"
        case screenClass = "screen_class"
        case stepNumber = "step_number"
        case stepName = "step_name"
        case tabName = "tab_name"
        case previousTab = "previous_tab"
        case actionType = "action_type"
        case actionName = "action_name"
        case contentId = "content_id"
        case contentType = "content_type"
        case contentName = "content_name"
        case duration = "duration"
        case success = "success"
        case method = "method"
        case source = "source"
        case streakDays = "streak_days"
        case levelName = "level_name"
        case previousLevel = "previous_level"
        case badgeName = "badge_name"
        case moodScore = "mood_score"
        case urgeScore = "urge_score"
        case messageCount = "message_count"
        case lessonId = "lesson_id"
        case sectionId = "section_id"
        case articleId = "article_id"
        case rating = "rating"
        case enabled = "enabled"
        case paywallId = "paywall_id"
        case productId = "product_id"
        case price = "price"
        case currency = "currency"
        case subscriptionType = "subscription_type"
        case errorMessage = "error_message"
        case quizAnswer = "quiz_answer"
        case questionId = "question_id"
        case exName = "ex_name_set"
        case exGender = "ex_gender"
        case userName = "user_name_set"
        case timestamp = "timestamp"
        case sessionDuration = "session_duration"
        case itemCount = "item_count"
    }
    
    // MARK: - Screen Names
    
    enum ScreenName: String {
        case launch = "Launch"
        case onboarding1 = "Onboarding_Welcome"
        case onboarding2 = "Onboarding_Quiz"
        case onboarding3 = "Onboarding_Features"
        case onboardingNotification = "Onboarding_Notification"
        case onboarding4 = "Onboarding_Social_Proof"
        case onboarding5 = "Onboarding_Rating"
        case home = "Home"
        case analytics = "Analytics"
        case aiAgent = "AI_Agent"
        case myWhy = "My_Why"
        case learning = "Learning"
        case settings = "Settings"
        case panic = "Panic_SOS"
        case meditate = "Meditate"
        case roastMe = "Roast_Me"
        case powerActions = "Power_Actions"
        case articleDetail = "Article_Detail"
        case addWhy = "Add_Why"
        case badges = "Badges"
        case allLevels = "All_Levels"
        case exQuiz = "Ex_Quiz"
        case breathingGame = "Breathing_Game"
        case streakCelebration = "Streak_Celebration"
    }
    
    // MARK: - Core Tracking Methods
    
    /// Log any custom event with parameters
    func logEvent(_ event: EventName, parameters: [ParamKey: Any]? = nil) {
        var params: [String: Any]?
        if let parameters = parameters {
            params = Dictionary(uniqueKeysWithValues: parameters.map { ($0.key.rawValue, $0.value) })
        }
        Analytics.logEvent(event.rawValue, parameters: params)
        #if DEBUG
        print("🔥 Firebase: \(event.rawValue) - \(params ?? [:])")
        #endif
    }
    
    /// Log screen view
    func logScreenView(_ screen: ScreenName, screenClass: String? = nil) {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screen.rawValue,
            AnalyticsParameterScreenClass: screenClass ?? screen.rawValue
        ])
        #if DEBUG
        print("🔥 Firebase Screen: \(screen.rawValue)")
        #endif
    }
    
    // MARK: - App Lifecycle
    
    func trackAppOpen(isReturningUser: Bool) {
        logEvent(.appOpen, parameters: [
            .source: isReturningUser ? "returning" : "new",
            .timestamp: ISO8601DateFormatter().string(from: Date())
        ])
    }
    
    func trackSessionStart() {
        logEvent(.sessionStart, parameters: [
            .timestamp: ISO8601DateFormatter().string(from: Date())
        ])
    }
    
    // MARK: - Onboarding Funnel
    
    func trackOnboardingStart() {
        logEvent(.onboardingStart, parameters: [
            .timestamp: ISO8601DateFormatter().string(from: Date())
        ])
    }
    
    func trackOnboardingStep(step: Int, name: String) {
        logEvent(.onboardingStep, parameters: [
            .stepNumber: step,
            .stepName: name
        ])
    }
    
    func trackOnboardingQuizStart() {
        logEvent(.onboardingQuizStart)
    }
    
    func trackOnboardingQuizAnswer(questionId: String, answer: String) {
        logEvent(.onboardingQuizAnswer, parameters: [
            .questionId: questionId,
            .quizAnswer: answer
        ])
    }
    
    func trackOnboardingQuizComplete(exNameSet: Bool, exGender: String) {
        logEvent(.onboardingQuizComplete, parameters: [
            .exName: exNameSet,
            .exGender: exGender
        ])
    }
    
    func trackOnboardingNotificationPrompt() {
        logEvent(.onboardingNotificationPrompt)
    }
    
    func trackOnboardingNotificationResponse(enabled: Bool) {
        logEvent(.onboardingNotificationResponse, parameters: [
            .enabled: enabled
        ])
    }
    
    func trackOnboardingRating(rating: Int) {
        logEvent(.onboardingRating, parameters: [
            .rating: rating
        ])
    }
    
    func trackOnboardingComplete() {
        logEvent(.onboardingComplete, parameters: [
            .timestamp: ISO8601DateFormatter().string(from: Date())
        ])
    }
    
    // MARK: - Tab Navigation
    
    func trackTabSwitch(from previousTab: String?, to newTab: String) {
        var params: [ParamKey: Any] = [.tabName: newTab]
        if let prev = previousTab {
            params[.previousTab] = prev
        }
        logEvent(.tabSwitch, parameters: params)
    }
    
    // MARK: - Panic/SOS Features
    
    func trackPanicButtonTap(source: String = "home") {
        logEvent(.panicButtonTap, parameters: [
            .source: source
        ])
    }
    
    func trackPanicViewOpen() {
        logScreenView(.panic)
        logEvent(.panicViewOpen)
    }
    
    func trackPanicViewAction(action: String) {
        logEvent(.panicViewAction, parameters: [
            .actionName: action
        ])
    }
    
    // MARK: - Breathe/Meditate
    
    func trackBreatheOpen() {
        logScreenView(.meditate)
        logEvent(.breatheOpen)
    }
    
    func trackBreathingSessionStart() {
        logEvent(.breathingSessionStart)
    }
    
    func trackBreathingSessionComplete(durationSeconds: Int) {
        logEvent(.breathingSessionComplete, parameters: [
            .duration: durationSeconds,
            .success: true
        ])
    }
    
    func trackBurnTextStart() {
        logEvent(.burnTextStart)
    }
    
    func trackBurnTextComplete() {
        logEvent(.burnTextComplete, parameters: [
            .success: true
        ])
    }
    
    // MARK: - Roast Me
    
    func trackRoastMeOpen() {
        logScreenView(.roastMe)
        logEvent(.roastMeOpen)
    }
    
    func trackRoastGenerated() {
        logEvent(.roastGenerated)
    }
    
    func trackRoastShared() {
        logEvent(.roastShared)
    }
    
    // MARK: - Power Actions
    
    func trackPowerActionsOpen() {
        logScreenView(.powerActions)
        logEvent(.powerActionsOpen)
    }
    
    func trackPowerActionTap(actionName: String) {
        logEvent(.powerActionTap, parameters: [
            .actionName: actionName
        ])
    }
    
    func trackPowerActionComplete(actionName: String) {
        logEvent(.powerActionComplete, parameters: [
            .actionName: actionName,
            .success: true
        ])
    }
    
    // MARK: - AI Agent
    
    func trackAiAgentOpen() {
        logScreenView(.aiAgent)
        logEvent(.aiAgentOpen)
    }
    
    func trackAiMessageSent(messageLength: Int) {
        logEvent(.aiMessageSent, parameters: [
            .contentType: "user_message",
            .duration: messageLength
        ])
    }
    
    func trackAiResponseReceived() {
        logEvent(.aiResponseReceived)
    }
    
    func trackAiConversationLength(messageCount: Int) {
        logEvent(.aiConversationLength, parameters: [
            .messageCount: messageCount
        ])
    }
    
    func trackAiLimitReached() {
        logEvent(.aiLimitReached)
    }
    
    // MARK: - My Why
    
    func trackMyWhyOpen(itemCount: Int) {
        logScreenView(.myWhy)
        logEvent(.myWhyOpen, parameters: [
            .itemCount: itemCount
        ])
    }
    
    func trackWhyItemAdd(hasImage: Bool) {
        logEvent(.whyItemAdd, parameters: [
            .contentType: hasImage ? "with_image" : "text_only"
        ])
    }
    
    func trackWhyItemDelete() {
        logEvent(.whyItemDelete)
    }
    
    func trackWhyItemView(itemId: String) {
        logEvent(.whyItemView, parameters: [
            .contentId: itemId
        ])
    }
    
    // MARK: - Learning
    
    func trackLearningOpen(completedCount: Int, totalCount: Int) {
        logScreenView(.learning)
        logEvent(.learningOpen, parameters: [
            .itemCount: completedCount,
            .contentType: "\(completedCount)/\(totalCount)"
        ])
    }
    
    func trackLessonStart(lessonId: String, sectionId: String) {
        logEvent(.lessonStart, parameters: [
            .lessonId: lessonId,
            .sectionId: sectionId
        ])
    }
    
    func trackLessonComplete(lessonId: String, sectionId: String) {
        logEvent(.lessonComplete, parameters: [
            .lessonId: lessonId,
            .sectionId: sectionId,
            .success: true
        ])
    }
    
    func trackArticleOpen(articleId: String, articleTitle: String) {
        logScreenView(.articleDetail)
        logEvent(.articleOpen, parameters: [
            .articleId: articleId,
            .contentName: articleTitle
        ])
    }
    
    func trackArticleComplete(articleId: String) {
        logEvent(.articleComplete, parameters: [
            .articleId: articleId,
            .success: true
        ])
    }
    
    func trackSectionExpand(sectionId: String, sectionTitle: String) {
        logEvent(.sectionExpand, parameters: [
            .sectionId: sectionId,
            .contentName: sectionTitle
        ])
    }
    
    // MARK: - Analytics/Progress View
    
    func trackAnalyticsViewOpen(streakDays: Int, level: String) {
        logScreenView(.analytics)
        logEvent(.analyticsViewOpen, parameters: [
            .streakDays: streakDays,
            .levelName: level
        ])
    }
    
    func trackLevelProgressView(level: String, progress: Double) {
        logEvent(.levelProgressView, parameters: [
            .levelName: level,
            .duration: Int(progress * 100)
        ])
    }
    
    func trackBadgesView(earnedCount: Int, totalCount: Int) {
        logScreenView(.badges)
        logEvent(.badgesView, parameters: [
            .itemCount: earnedCount,
            .contentType: "\(earnedCount)/\(totalCount)"
        ])
    }
    
    func trackAllLevelsView() {
        logScreenView(.allLevels)
        logEvent(.allLevelsView)
    }
    
    // MARK: - Streak & Progress
    
    func trackStreakMilestone(days: Int, level: String) {
        logEvent(.streakMilestone, parameters: [
            .streakDays: days,
            .levelName: level
        ])
    }
    
    func trackLevelUp(from previousLevel: String, to newLevel: String, streakDays: Int) {
        logEvent(.levelUp, parameters: [
            .previousLevel: previousLevel,
            .levelName: newLevel,
            .streakDays: streakDays
        ])
    }
    
    func trackBadgeEarned(badgeName: String) {
        logEvent(.badgeEarned, parameters: [
            .badgeName: badgeName
        ])
    }
    
    func trackDailyCheckIn(moodScore: Int, urgeScore: Int, hasNote: Bool) {
        logEvent(.dailyCheckIn, parameters: [
            .moodScore: moodScore,
            .urgeScore: urgeScore,
            .contentType: hasNote ? "with_note" : "no_note"
        ])
    }
    
    func trackRelapse(previousStreak: Int) {
        logEvent(.relapse, parameters: [
            .streakDays: previousStreak
        ])
    }
    
    func trackStreakReset(reason: String) {
        logEvent(.streakReset, parameters: [
            .source: reason
        ])
    }
    
    // MARK: - Settings
    
    func trackSettingsOpen() {
        logScreenView(.settings)
        logEvent(.settingsOpen)
    }
    
    func trackNotificationToggle(enabled: Bool, type: String) {
        logEvent(.notificationToggle, parameters: [
            .enabled: enabled,
            .contentType: type
        ])
    }
    
    func trackStartFresh() {
        logEvent(.startFresh)
    }
    
    func trackRateApp(source: String) {
        logEvent(.rateApp, parameters: [
            .source: source
        ])
    }
    
    func trackShareApp(method: String) {
        logEvent(.shareApp, parameters: [
            .method: method
        ])
    }
    
    func trackContactSupport() {
        logEvent(.contactSupport)
    }
    
    func trackPrivacyPolicyView() {
        logEvent(.privacyPolicyView)
    }
    
    func trackTermsView() {
        logEvent(.termsView)
    }
    
    // MARK: - Subscription/Paywall
    
    func trackPaywallView(paywallId: String, source: String) {
        logEvent(.paywallView, parameters: [
            .paywallId: paywallId,
            .source: source
        ])
    }
    
    func trackPaywallDismiss(paywallId: String) {
        logEvent(.paywallDismiss, parameters: [
            .paywallId: paywallId
        ])
    }
    
    func trackSubscriptionStart(productId: String, price: Double, currency: String, type: String, isTrial: Bool) {
        let event: EventName = isTrial ? .trialStart : .subscriptionStart
        logEvent(event, parameters: [
            .productId: productId,
            .price: price,
            .currency: currency,
            .subscriptionType: type
        ])
    }
    
    func trackPurchaseComplete(productId: String, price: Double, currency: String) {
        logEvent(.purchaseComplete, parameters: [
            .productId: productId,
            .price: price,
            .currency: currency,
            .success: true
        ])
        
        // Also log standard Firebase purchase event
        Analytics.logEvent(AnalyticsEventPurchase, parameters: [
            AnalyticsParameterItemID: productId,
            AnalyticsParameterPrice: price,
            AnalyticsParameterCurrency: currency
        ])
    }
    
    func trackPurchaseFailed(productId: String, error: String) {
        logEvent(.purchaseFailed, parameters: [
            .productId: productId,
            .errorMessage: error,
            .success: false
        ])
    }
    
    func trackRestorePurchase(success: Bool) {
        logEvent(.restorePurchase, parameters: [
            .success: success
        ])
    }
    
    // MARK: - Engagement
    
    func trackQuoteView(quoteId: String? = nil) {
        logEvent(.quoteView, parameters: quoteId != nil ? [.contentId: quoteId!] : nil)
    }
    
    func trackQuoteSaved() {
        logEvent(.quoteSaved)
    }
    
    func trackExQuizOpen() {
        logScreenView(.exQuiz)
        logEvent(.exQuizOpen)
    }
    
    func trackExQuizComplete(score: Int) {
        logEvent(.exQuizComplete, parameters: [
            .rating: score,
            .success: true
        ])
    }
    
    func trackShareContent(contentType: String, contentId: String) {
        logEvent(.shareContent, parameters: [
            .contentType: contentType,
            .contentId: contentId
        ])
        
        // Also log standard Firebase share event
        Analytics.logEvent(AnalyticsEventShare, parameters: [
            AnalyticsParameterContentType: contentType,
            AnalyticsParameterItemID: contentId
        ])
    }
    
    // MARK: - User Properties
    
    func setUserProperty(_ value: String?, forName name: String) {
        Analytics.setUserProperty(value, forName: name)
        #if DEBUG
        print("🔥 Firebase User Property: \(name) = \(value ?? "nil")")
        #endif
    }
    
    func setUserLevel(_ level: String) {
        setUserProperty(level, forName: "current_level")
    }
    
    func setUserStreakDays(_ days: Int) {
        setUserProperty(String(days), forName: "streak_days")
    }
    
    func setSubscriptionStatus(_ status: String) {
        setUserProperty(status, forName: "subscription_status")
    }
    
    func setOnboardingComplete(_ complete: Bool) {
        setUserProperty(complete ? "true" : "false", forName: "onboarding_complete")
    }
    
    func setNotificationsEnabled(_ enabled: Bool) {
        setUserProperty(enabled ? "true" : "false", forName: "notifications_enabled")
    }
}

// MARK: - Convenience Typealias

typealias FA = FirebaseAnalyticsManager
