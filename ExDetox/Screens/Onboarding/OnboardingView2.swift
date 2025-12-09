import SwiftUI
import Charts

// MARK: - Models

struct OnboardingMessage: Identifiable, Equatable {
    let id = UUID()
    let content: OnboardingMessageContent
    let isUser: Bool
    var isTyping: Bool = false
    
    static func == (lhs: OnboardingMessage, rhs: OnboardingMessage) -> Bool {
        lhs.id == rhs.id && lhs.isTyping == rhs.isTyping
    }
}

enum OnboardingMessageContent: Equatable {
    case text(String)
    case chart(ChartType)
    case contract
    case cta
    
    enum ChartType {
        case healing
        case rollercoaster
        case success
    }
}

// MARK: - Main View

struct OnboardingView2: View {
    @Environment(Router.self) private var router
    @Environment(UserProfileStore.self) private var userProfileStore
    
    // MARK: State
    @State private var messages: [OnboardingMessage] = []
    @State private var currentStep = 0
    @State private var isTyping = false
    @State private var showInput = false
    @State private var showIntro = true
    @State private var showFinalOverlay = false
    
    // Focus State
    @FocusState private var isInputFocused: Bool
    
    // User Data
    @State private var userName = ""
    @State private var userGender = ""
    @State private var exName = ""
    @State private var exGender = ""
    @State private var duration = ""
    @State private var initiator = ""
    @State private var contactStatus = ""
    @State private var socialStatus = ""
    @State private var sleepQuality = ""
    @State private var mood = ""
    
    // Contract Data
    @State private var signatureLines: [Line] = []
    @State private var currentLine = Line(points: [])
    @State private var isSigned = false
    
    var body: some View {
        ZStack {
            Color(red: 249/255, green: 249/255, blue: 249/255).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                if !showIntro {
                    HeaderView(progress: Double(currentStep) / 12.0, isTyping: isTyping)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(10)
                }
                
                // Chat Area
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            Color.clear.frame(height: 10)
                            
                            ForEach(messages) { message in
                                OnboardingChatBubble(message: message, userName: userName, signatureLines: $signatureLines, currentLine: $currentLine, isSigned: $isSigned)
                                    .id(message.id)
                            }
                            
                            if isTyping {
                                HStack {
                                    TypingIndicator()
                                    Spacer()
                                }
                                .padding(.leading, 20)
                                .transition(.opacity)
                                .id("typing")
                            }
                            
                            Color.clear.frame(height: 100)
                                .id("bottom")
                        }
                        .padding(.horizontal, 0) // Bubbles handle their own padding
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .onChange(of: messages.count) {
                        scrollToBottom(proxy: proxy)
                    }
                    .onChange(of: isTyping) {
                        if isTyping { scrollToBottom(proxy: proxy) }
                    }
                    .onChange(of: showInput) {
                        if showInput {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                scrollToBottom(proxy: proxy)
                            }
                        }
                    }
                }
            }
            
            // Intro Overlay
            if showIntro {
                IntroOverlayView {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showIntro = false
                    }
                    startConversation()
                }
                .zIndex(100)
            }
            
            if showFinalOverlay {
                FinalCelebrationView(signatureLines: signatureLines) {
                    router.navigate(.onboarding3)
                }
                .transition(.opacity.combined(with: .scale))
                .zIndex(200)
            }
        }
        .safeAreaInset(edge: .bottom) {
            if showInput {
                InputArea(
                    step: currentStep,
                    inputText: $userName, // Logic handled inside
                    isFocused: $isInputFocused,
                    onSendText: handleTextInput,
                    onSelectOption: handleSelection
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .background(
                    VisualEffectBlur(blurStyle: .systemMaterial)
                        .ignoresSafeArea()
                )
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
        .onChange(of: isSigned) { _, signed in
            if signed && currentStep == 12 {
                handleContractSigned()
            }
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
            proxy.scrollTo("bottom", anchor: .bottom)
        }
    }
    
    // MARK: - Conversation Logic
    
    func startConversation() {
        addAppMessage("Hey. I'm ExDetox. 👋", delay: 0.2) {
            addAppMessage("I'm going to ask you a few questions to build your personalized recovery plan.") {
                addAppMessage("Trust the process. We'll get you through this.") {
                    addAppMessage("First things first... what should I call you?") {
                        showInput = true
                        isInputFocused = true
                    }
                }
            }
        }
    }
    
    func addAppMessage(_ text: String, delay: Double = 0.5, completion: (() -> Void)? = nil) {
        isTyping = true
        showInput = false
        isInputFocused = false
        
        // Much faster typing duration
        // Base: 0.015s per char, Min: 0.5s, Max: 1.5s
        let typingDuration = min(max(Double(text.count) * 0.015, 0.5), 1.5)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            // Keep typing for a bit
            DispatchQueue.main.asyncAfter(deadline: .now() + typingDuration) {
                isTyping = false
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    messages.append(OnboardingMessage(content: .text(text), isUser: false))
                }
                
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.prepare()
                generator.impactOccurred()
                
                completion?()
            }
        }
    }
    
    func addAppWidget(_ content: OnboardingMessageContent, delay: Double = 0.3, completion: (() -> Void)? = nil) {
        isTyping = true
        showInput = false
        isInputFocused = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            isTyping = false
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                messages.append(OnboardingMessage(content: content, isUser: false))
            }
            
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.prepare()
            generator.impactOccurred()
            
            completion?()
        }
    }
    
    func addUserMessage(_ text: String) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            messages.append(OnboardingMessage(content: .text(text), isUser: true))
        }
        showInput = false
        isInputFocused = false
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // MARK: - Handlers with Context
    
    func handleTextInput(_ text: String) {
        if currentStep == 0 { // Name
            userName = text
            addUserMessage(text)
            saveData()
            
            addAppMessage("Nice to meet you, \(text).") {
                addAppMessage("To help me understand you better... how do you identify?") {
                    currentStep = 1
                    showInput = true
                }
            }
        } else if currentStep == 2 { // Ex Name
            exName = text
            addUserMessage(text)
            saveData()
            
            addAppMessage("Got it. \(text).") {
                addAppMessage("We won't say that name too loud around here.") {
                    addAppMessage("Just for my records, who are they?") {
                        currentStep = 3
                        showInput = true
                    }
                }
            }
        }
    }
    
    func handleSelection(_ selection: String) {
        addUserMessage(selection)
        
        switch currentStep {
        case 1: // Gender
            userGender = selection
            saveData()
            addAppMessage("Thanks.") {
                addAppMessage("Now, the hard part.") {
                    addAppMessage("Who are we forgetting today?") {
                        currentStep = 2 // Triggers text input for Ex Name
                        showInput = true
                        isInputFocused = true
                    }
                }
            }
            
        case 3: // Ex Gender
            exGender = selection
            saveData()
            let response = selection.contains("Red Flag") ? "🚩 Indeed." : "Understood."
            addAppMessage(response) {
                addAppMessage("How long did this... situation last?") {
                    currentStep = 4
                    showInput = true
                }
            }
            
        case 4: // Duration
            duration = selection
            saveData()
            let isLong = selection.contains("years") || selection.contains("3+")
            let response = isLong ? "That's a significant chapter of your life." : "Short and intense?"
            addAppMessage(response) {
                addAppMessage("Who pulled the plug?") {
                    currentStep = 5
                    showInput = true
                }
            }
            
        case 5: // Initiator
            initiator = selection
            saveData()
            
            let response: String
            if selection.contains("I did") { response = "Bold move. Respect." }
            else if selection.contains("They did") { response = "Their loss. Truly." }
            else { response = "It's never simple, is it?" }
            
            addAppMessage(response) {
                addAppMessage("Based on what you told me, here's your estimated healing trajectory.") {
                    addAppWidget(.chart(.healing)) {
                        addAppMessage("Stick with the plan, and that pain curve drops fast.") {
                            addAppMessage("Where do you stand right now with them?") {
                                currentStep = 6
                                showInput = true
                            }
                        }
                    }
                }
            }
            
        case 6: // Contact Status
            contactStatus = selection
            saveData()
            let response = selection.contains("No Contact") ? "Perfect. You're already winning." : "We'll need to work on that."
            addAppMessage(response) {
                addAppMessage("What about social media? Be real with me.") {
                    currentStep = 7
                    showInput = true
                }
            }
            
        case 7: // Social
            socialStatus = selection
            saveData()
            
            addAppMessage("I see.") {
                addAppMessage("Healing isn't a straight line. It looks more like this:") {
                    addAppWidget(.chart(.rollercoaster)) {
                        addAppMessage("You might feel down sometimes, and that's okay.") {
                            addAppMessage("How has your sleep been lately?") {
                                currentStep = 8
                                showInput = true
                            }
                        }
                    }
                }
            }
            
        case 8: // Sleep
            sleepQuality = selection
            saveData()
            let response = selection.contains("Like a baby") ? "That's a superpower." : "We'll fix that. Rest is fuel."
            addAppMessage(response) {
                addAppMessage("How's your mood right this second?") {
                    currentStep = 9
                    showInput = true
                }
            }
            
        case 9: // Mood
            mood = selection
            saveData()
            
            addAppMessage("Let's change that trajectory.") {
                addAppWidget(.chart(.success)) {
                    addAppMessage("99% of people who stick to the detox succeed.") {
                        addAppMessage("Are you ready to commit?") {
                            addAppMessage("Sign the No-Contact Contract to begin.") {
                                currentStep = 12
                                addAppWidget(.contract)
                            }
                        }
                    }
                }
            }
            
        default:
            break
        }
    }
    
    func handleContractSigned() {
        saveData()
        showInput = false
        isTyping = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            messages.removeAll()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showFinalOverlay = true
            }
        }
    }
    
    func saveData() {
        userProfileStore.profile.name = userName
        userProfileStore.profile.gender = userGender
        userProfileStore.profile.exName = exName
        userProfileStore.profile.exGender = exGender
        userProfileStore.profile.relationshipDuration = duration
        userProfileStore.profile.breakupInitiator = initiator
        userProfileStore.profile.contactStatus = contactStatus
        userProfileStore.profile.socialMediaHabits = socialStatus
        userProfileStore.profile.sleepQuality = sleepQuality
        userProfileStore.profile.mood = mood
    }
}

// MARK: - Subviews

struct HeaderView: View {
    let progress: Double
    let isTyping: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.black.opacity(0.9))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text("AI")
                            .font(.system(size: 13, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("ExDetox")
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.bold)
                    Text(isTyping ? "typing…" : "online")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .animation(.easeInOut, value: isTyping)
                }
                
                Spacer()
                
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.15))
                        .frame(width: 110, height: 6)
                    
                    Capsule()
                        .fill(Color.black)
                        .frame(width: 110 * progress, height: 6)
                        .animation(.spring, value: progress)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.98))
            
            Divider().opacity(0.6)
        }
    }
}

struct IntroOverlayView: View {
    let onFinish: () -> Void
    @State private var opacity = 0.0
    @State private var textOpacity = 0.0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("🕵️")
                    .font(.system(size: 80))
                    .scaleEffect(textOpacity > 0 ? 1 : 0.5)
                    .animation(.spring, value: textOpacity)
                
                Text("Analyzing your situation...")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("We're going to build a custom\nrecovery plan just for you.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .opacity(textOpacity)
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.5)) { textOpacity = 1 }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                onFinish()
            }
        }
    }
}

struct OnboardingChatBubble: View {
    @Environment(Router.self) private var router
    let message: OnboardingMessage
    let userName: String
    @Binding var signatureLines: [Line]
    @Binding var currentLine: Line
    @Binding var isSigned: Bool
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isUser {
                Spacer()
            } else if !message.isUser {
                if case .cta = message.content {
                    // No avatar for CTA to center it nicely
                    EmptyView()
                } else {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Text("AI")
                                .font(.system(size: 12, weight: .black))
                                .foregroundColor(.white)
                        )
                }
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading) {
                switch message.content {
                case .text(let text):
                    Text(text)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(message.isUser ? .white : .primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(message.isUser ? Color.black : Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .shadow(color: .black.opacity(0.04), radius: 5, x: 0, y: 2)
                    
                case .chart(let type):
                    Group {
                        switch type {
                        case .healing: RecoveryTimelineChartView(isVisible: true)
                        case .rollercoaster: EmotionalRollercoasterView(isVisible: true)
                        case .success: SuccessRateChartView(isVisible: true)
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.75) // Cinematic width
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                    
                case .contract:
                    ContractCard(
                        name: userName,
                        lines: $signatureLines,
                        currentLine: $currentLine,
                        isSigned: $isSigned
                    )
                    .frame(width: UIScreen.main.bounds.width * 0.8)
                    
                case .cta:
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.prepare()
                        generator.impactOccurred()
                        router.navigate(.onboarding3)
                    }) {
                        Text("Start My Journey")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.black)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.8)
                    .padding(.top, 8)
                }
            }
            
            if !message.isUser {
                Spacer()
            }
        }
        // Center CTA
        .frame(maxWidth: .infinity, alignment: message.isUser ? .trailing : .leading)
        .padding(.horizontal, 20) // Consistent side padding
        .transition(.asymmetric(
            insertion: .scale(scale: 0.9, anchor: message.isUser ? .bottomTrailing : .bottomLeading).combined(with: .opacity),
            removal: .opacity
        ))
    }
}

struct TypingIndicator: View {
    @State private var offset: CGFloat = 0
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            Circle()
                .fill(Color.black)
                .frame(width: 32, height: 32)
                .overlay(Text("AI").font(.system(size: 12, weight: .black)).foregroundColor(.white))
            
            HStack(spacing: 4) {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(Color.gray.opacity(0.4))
                        .frame(width: 6, height: 6)
                        .offset(y: offset)
                        .animation(Animation.easeInOut(duration: 0.5).repeatForever().delay(Double(i) * 0.15), value: offset)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 3)
        }
        .onAppear { offset = -4 }
    }
}

struct FinalCelebrationView: View {
    let signatureLines: [Line]
    let onContinue: () -> Void
    @State private var showOfficial = false
    @State private var showWelcome = false
    @State private var showCTA = false
    
    var body: some View {
        ZStack {
            Color(red: 249/255, green: 249/255, blue: 249/255).ignoresSafeArea()
            
            VStack(spacing: 18) {
                if showOfficial {
                    Text("It's official. 🤝")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                if showWelcome {
                    Text("Welcome to your new life.")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                if showWelcome {
                    VStack(spacing: 10) {
                        Text("Signed & sealed")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white)
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(Color.gray.opacity(0.2), lineWidth: 1)
                            Canvas { context, size in
                                for line in signatureLines {
                                    var path = Path()
                                    path.addLines(line.points)
                                    context.stroke(path, with: .color(.black), lineWidth: 2)
                                }
                            }
                            .padding(16)
                        }
                        .frame(height: 160)
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 6)
                        .transition(.opacity.combined(with: .scale))
                    }
                    .padding(.horizontal, 12)
                }
                
                if showCTA {
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.prepare()
                        generator.impactOccurred()
                        onContinue()
                    }) {
                        Text("Start My Journey")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: 320)
                            .padding(.vertical, 18)
                            .background(Color.black)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
                    }
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
                    .padding(.top, 10)
                }
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
            .onAppear {
                withAnimation(.easeOut(duration: 0.6)) { showOfficial = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation(.easeOut(duration: 0.6)) { showWelcome = true }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { showCTA = true }
                }
            }
        }
    }
}

struct InputArea: View {
    let step: Int
    @Binding var inputText: String
    var isFocused: FocusState<Bool>.Binding
    let onSendText: (String) -> Void
    let onSelectOption: (String) -> Void
    
    @State private var localText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .opacity(0)
            
            VStack {
                if isTextInputStep {
                    HStack(spacing: 12) {
                        TextField("Type your answer...", text: $localText)
                            .focused(isFocused)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .cornerRadius(28)
                            .overlay(RoundedRectangle(cornerRadius: 28).stroke(Color.gray.opacity(0.15), lineWidth: 1))
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                            .submitLabel(.send)
                            .onSubmit {
                                send()
                            }
                        
                        Button(action: send) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 44))
                                .foregroundColor(localText.isEmpty ? .gray.opacity(0.3) : .black)
                                .symbolEffect(.bounce, value: localText.isEmpty)
                                .background(Circle().fill(Color.white).padding(2))
                        }
                        .disabled(localText.isEmpty)
                    }
                    .padding(.horizontal, 24)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(optionsForStep, id: \.self) { option in
                                Button(action: { onSelectOption(option) }) {
                                    Text(option)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 16)
                                        .background(Color.black)
                                        .cornerRadius(24)
                                        .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 10)
        }
        .padding(.bottom, 20)
    }
    
    func send() {
        if !localText.isEmpty {
            onSendText(localText)
            localText = ""
        }
    }
    
    var isTextInputStep: Bool {
        return step == 0 || step == 2
    }
    
    var optionsForStep: [String] {
        switch step {
        case 1: return ["Male", "Female", "Non-binary"]
        case 3: return ["Male", "Female", "Red Flag 🚩"]
        case 4: return ["< 3 months", "3-6 months", "6m-1y", "1-3y", "3y+"]
        case 5: return ["I did (Boss move)", "They did", "Mutual", "Complicated"]
        case 6: return ["No Contact", "Texting", "Stalking", "Living together"]
        case 7: return ["Blocked", "Muted", "Looking", "FBI Mode"]
        case 8: return ["Like a baby", "Tossing & turning", "Dreaming about them", "What is sleep?"]
        case 9: return ["Thriving ✨", "Okay-ish 😐", "Sad boi hours 😢", "Rage mode 🤬"]
        default: return []
        }
    }
}

// MARK: - Improved Charts

struct RecoveryTimelineChartView: View {
    var isVisible: Bool
    @State private var appear = false
    
    let data = [
        (day: "Start", value: 100),
        (day: "Day 7", value: 85),
        (day: "Day 14", value: 60),
        (day: "Day 21", value: 40),
        (day: "Day 30", value: 10)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Healing Path")
                .font(.headline)
                .padding(.leading, 8)
            
            Chart {
                ForEach(data, id: \.day) { item in
                    LineMark(
                        x: .value("Time", item.day),
                        y: .value("Pain", appear ? item.value : 0)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(LinearGradient(colors: [.pink, .indigo], startPoint: .top, endPoint: .bottom))
                    .lineStyle(StrokeStyle(lineWidth: 4, lineCap: .round))
                    
                    AreaMark(
                        x: .value("Time", item.day),
                        y: .value("Pain", appear ? item.value : 0)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(LinearGradient(colors: [.pink.opacity(0.2), .clear], startPoint: .top, endPoint: .bottom))
                }
            }
            .chartYAxis(.hidden)
            .frame(height: 220)
            .padding(.top, 10)
        }
        .padding(20)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5)) { appear = true }
        }
    }
}

struct EmotionalRollercoasterView: View {
    var isVisible: Bool
    @State private var progress: CGFloat = 0.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("The Reality")
                .font(.headline)
                .padding(.leading, 8)
            
            ZStack {
                // Background track
                Path { path in
                    path.move(to: CGPoint(x: 20, y: 150))
                    path.addCurve(to: CGPoint(x: 280, y: 50), control1: CGPoint(x: 100, y: 0), control2: CGPoint(x: 200, y: 200))
                }
                .stroke(Color.gray.opacity(0.1), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                
                // Animated path
                Path { path in
                    path.move(to: CGPoint(x: 20, y: 150))
                    path.addCurve(to: CGPoint(x: 280, y: 50), control1: CGPoint(x: 100, y: 0), control2: CGPoint(x: 200, y: 200))
                }
                .trim(from: 0, to: progress)
                .stroke(LinearGradient(colors: [.orange, .pink], startPoint: .leading, endPoint: .trailing), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                
                // Dot
                if progress > 0.01 {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 14, height: 14)
                        .shadow(radius: 2)
                        .position(x: 140, y: 80) // Approximated position for visual
                        .overlay(
                            Text("You")
                                .font(.caption2).bold()
                                .padding(4).background(Color.black).foregroundColor(.white).cornerRadius(6)
                                .offset(y: -25)
                                .position(x: 140, y: 80)
                        )
                        .opacity(progress > 0.4 ? 1 : 0)
                }
            }
            .frame(height: 200)
        }
        .padding(20)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0)) { progress = 1.0 }
        }
    }
}

struct SuccessRateChartView: View {
    var isVisible: Bool
    @State private var barHeight: CGFloat = 0.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Success Probability")
                .font(.headline)
                .padding(.leading, 8)
            
            HStack(alignment: .bottom, spacing: 30) {
                VStack {
                    Text("Solo")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 40, height: 80 * barHeight) // 40% height relative scale
                    Text("40%")
                        .font(.caption).bold()
                }
                
                VStack {
                    Text("With ExDetox")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    RoundedRectangle(cornerRadius: 12)
                        .fill(LinearGradient(colors: [.pink, .indigo], startPoint: .bottom, endPoint: .top))
                        .frame(width: 40, height: 180 * barHeight)
                        .shadow(color: .pink.opacity(0.3), radius: 10)
                    Text("99%")
                        .font(.caption).bold()
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(20)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) { barHeight = 1.0 }
        }
    }
}

struct ContractCard: View {
    let name: String
    @Binding var lines: [Line]
    @Binding var currentLine: Line
    @Binding var isSigned: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Text("NO-CONTACT PLEDGE")
                .font(.headline)
                .tracking(2)
                .opacity(0.5)
            
            Text("I, \(name), hereby promise to stop texting, calling, or checking up on my ex. It's time to focus on me.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal)
            
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 245/255, green: 245/255, blue: 245/255))
                    .frame(height: 120)
                
                if !isSigned {
                    Text("Sign Here")
                        .font(.custom("Snell Roundhand", size: 30))
                        .foregroundColor(.gray.opacity(0.3))
                }
                
                Canvas { context, size in
                    for line in lines {
                        var path = Path()
                        path.addLines(line.points)
                        context.stroke(path, with: .color(.black), lineWidth: 2)
                    }
                    var currentPath = Path()
                    currentPath.addLines(currentLine.points)
                    context.stroke(currentPath, with: .color(.black), lineWidth: 2)
                }
                .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged({ value in
                        let newPoint = value.location
                        currentLine.points.append(newPoint)
                    })
                    .onEnded({ value in
                        self.lines.append(currentLine)
                        self.currentLine = Line(points: [])
                        
                        // Check if meaningful signature (more than just a tap)
                        let totalPoints = self.lines.reduce(0) { $0 + $1.points.count }
                        if totalPoints > 15 {
                            self.isSigned = true
                        }
                    })
                )
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.gray.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [5]))
            )
            
            if isSigned {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                    Text("Signed & Sealed")
                }
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.green)
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

// Helpers
struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView { UIVisualEffectView(effect: UIBlurEffect(style: blurStyle)) }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

struct Line { var points: [CGPoint] }

#Preview {
    OnboardingView2()
        .environment(Router())
        .environment(UserProfileStore())
}
