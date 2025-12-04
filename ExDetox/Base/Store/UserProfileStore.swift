import Foundation
import SwiftData

struct UserProfile: Codable, Equatable {
    var name: String
    var gender: String
    var exName: String
    var exGender: String
    var relationshipDuration: String
    var breakupInitiator: String
    var contactStatus: String
    var socialMediaHabits: String
    var sleepQuality: String
    var mood: String
    var excitementRating: Int
    var onboardingCompletedDate: Date?
    
    static var empty: UserProfile {
        UserProfile(
            name: "",
            gender: "",
            exName: "",
            exGender: "",
            relationshipDuration: "",
            breakupInitiator: "",
            contactStatus: "",
            socialMediaHabits: "",
            sleepQuality: "",
            mood: "",
            excitementRating: 0,
            onboardingCompletedDate: nil
        )
    }
    
    var isComplete: Bool {
        !name.isEmpty && !exName.isEmpty && onboardingCompletedDate != nil
    }
    
    var pronounForEx: String {
        switch exGender.lowercased() {
        case "male": return "he"
        case "female": return "she"
        default: return "they"
        }
    }
    
    var pronounForExPossessive: String {
        switch exGender.lowercased() {
        case "male": return "his"
        case "female": return "her"
        default: return "their"
        }
    }
    
    var capitalizedPronounForEx: String {
        pronounForEx.capitalized
    }
    
    var initialMoodScore: Int {
        switch mood {
        case "Thriving ✨": return 5
        case "Okay-ish 😐": return 3
        case "Sad boi hours 😢": return 2
        case "Rage mode 🤬": return 1
        default: return 3
        }
    }
    
    var initialUrgeScore: Int {
        switch contactStatus {
        case "No Contact (Clean streak)": return 3
        case "Texting occasionally": return 6
        case "Stalking silently": return 7
        case "Living together (Oof)": return 9
        default: return 5
        }
    }
}

@MainActor
@Observable
final class UserProfileStore {
    private let userDefaultsKey = "userProfile"
    
    var profile: UserProfile {
        didSet {
            save()
        }
    }
    
    var hasCompletedOnboarding: Bool {
        profile.isComplete
    }
    
    init() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            self.profile = decoded
        } else {
            self.profile = .empty
        }
    }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    func completeOnboarding() {
        profile.onboardingCompletedDate = Date()
        save()
    }
    
    func reset() {
        profile = .empty
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
}

@Model
final class UserProfileRecord {
    @Attribute(.unique) var id: UUID
    var name: String
    var gender: String
    var exName: String
    var exGender: String
    var relationshipDuration: String
    var breakupInitiator: String
    var contactStatus: String
    var socialMediaHabits: String
    var sleepQuality: String
    var mood: String
    var excitementRating: Int
    var onboardingCompletedDate: Date?
    
    init(
        id: UUID = UUID(),
        name: String = "",
        gender: String = "",
        exName: String = "",
        exGender: String = "",
        relationshipDuration: String = "",
        breakupInitiator: String = "",
        contactStatus: String = "",
        socialMediaHabits: String = "",
        sleepQuality: String = "",
        mood: String = "",
        excitementRating: Int = 0,
        onboardingCompletedDate: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.gender = gender
        self.exName = exName
        self.exGender = exGender
        self.relationshipDuration = relationshipDuration
        self.breakupInitiator = breakupInitiator
        self.contactStatus = contactStatus
        self.socialMediaHabits = socialMediaHabits
        self.sleepQuality = sleepQuality
        self.mood = mood
        self.excitementRating = excitementRating
        self.onboardingCompletedDate = onboardingCompletedDate
    }
    
    func toProfile() -> UserProfile {
        UserProfile(
            name: name,
            gender: gender,
            exName: exName,
            exGender: exGender,
            relationshipDuration: relationshipDuration,
            breakupInitiator: breakupInitiator,
            contactStatus: contactStatus,
            socialMediaHabits: socialMediaHabits,
            sleepQuality: sleepQuality,
            mood: mood,
            excitementRating: excitementRating,
            onboardingCompletedDate: onboardingCompletedDate
        )
    }
    
    func update(from profile: UserProfile) {
        name = profile.name
        gender = profile.gender
        exName = profile.exName
        exGender = profile.exGender
        relationshipDuration = profile.relationshipDuration
        breakupInitiator = profile.breakupInitiator
        contactStatus = profile.contactStatus
        socialMediaHabits = profile.socialMediaHabits
        sleepQuality = profile.sleepQuality
        mood = profile.mood
        excitementRating = profile.excitementRating
        onboardingCompletedDate = profile.onboardingCompletedDate
    }
}

