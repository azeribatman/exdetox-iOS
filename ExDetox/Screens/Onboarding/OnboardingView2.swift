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
    case bigText(String)
    case chart(ChartType)
    case contractPrompt
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
    @State private var showSigningSheet = false
    
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
            Color(hex: "F9F9F9").ignoresSafeArea()
            
            VStack(spacing: 0) {
                if !showIntro {
                    StoryProgressBar(progress: Double(currentStep) / 12.0)
                        .padding(.top, 8)
                        .padding(.horizontal, 16)
                        .transition(.opacity)
                        .zIndex(10)
                }
                
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            Color.clear.frame(height: 20)
                            
                            ForEach(messages) { message in
                                OnboardingChatBubble(
                                    message: message,
                                    userName: userName,
                                    onSignTap: {
                                        showSigningSheet = true
                                        Haptics.feedback(style: .medium)
                                    }
                                )
                                .id(message.id)
                            }
                            
                            if isTyping {
                                HStack {
                                    TypingIndicator()
                                    Spacer()
                                }
                                .padding(.leading, 24)
                                .transition(.opacity)
                                .id("typing")
                            }
                            
                            Color.clear.frame(height: 120)
                                .id("bottom")
                        }
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
            
            if showIntro {
                CinematicIntro {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showIntro = false
                    }
                    startConversation()
                }
                .zIndex(100)
            }
        }
        .safeAreaInset(edge: .bottom) {
            if showInput {
                InputArea(
                    step: currentStep,
                    inputText: $userName,
                    isFocused: $isInputFocused,
                    onSendText: handleTextInput,
                    onSelectOption: handleSelection
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .background(
                    VisualEffectBlur(blurStyle: .systemThinMaterial)
                        .ignoresSafeArea()
                )
            }
        }
        .fullScreenCover(isPresented: $showSigningSheet) {
            FullScreenSigningView(
                userName: userName,
                signatureLines: $signatureLines,
                currentLine: $currentLine,
                isSigned: $isSigned,
                onComplete: {
                    showSigningSheet = false
                    handleContractSigned()
                }
            )
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
            proxy.scrollTo("bottom", anchor: .bottom)
        }
    }
    
    // MARK: - Conversation Logic
    
    func startConversation() {
        addAppMessage("Hey you. 👋", delay: 0.3) {
            addAppMessage("You made it here.\nThat takes guts.") {
                addAppMessage("I'm gonna ask you some real questions.\nNo BS.") {
                    addAppMessage("What's your name?") {
                        showInput = true
                        isInputFocused = true
                    }
                }
            }
        }
    }
    
    func addAppMessage(_ text: String, delay: Double = 0.4, completion: (() -> Void)? = nil) {
        isTyping = true
        showInput = false
        isInputFocused = false
        
        let typingDuration = min(max(Double(text.count) * 0.012, 0.4), 1.2)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            DispatchQueue.main.asyncAfter(deadline: .now() + typingDuration) {
                isTyping = false
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    messages.append(OnboardingMessage(content: .text(text), isUser: false))
                }
                Haptics.feedback(style: .light)
                completion?()
            }
        }
    }
    
    func addBigMessage(_ text: String, delay: Double = 0.3, completion: (() -> Void)? = nil) {
        isTyping = false
        showInput = false
        isInputFocused = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                messages.append(OnboardingMessage(content: .bigText(text), isUser: false))
            }
            Haptics.notification(type: .success)
            completion?()
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
            Haptics.feedback(style: .medium)
            completion?()
        }
    }
    
    func addUserMessage(_ text: String) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            messages.append(OnboardingMessage(content: .text(text), isUser: true))
        }
        showInput = false
        isInputFocused = false
        Haptics.feedback(style: .light)
    }
    
    // MARK: - Handlers with Context
    
    func handleTextInput(_ text: String) {
        if currentStep == 0 {
            userName = text
            addUserMessage(text)
            saveData()
            
            addBigMessage("\(text).") {
                addAppMessage("I like that.") {
                    addAppMessage("How do you identify?") {
                        currentStep = 1
                        showInput = true
                    }
                }
            }
        } else if currentStep == 2 {
            exName = text
            addUserMessage(text)
            saveData()
            
            addAppMessage("...") {
                addBigMessage("\(text) 🚫") {
                    addAppMessage("We don't say that name here anymore.") {
                        addAppMessage("Who were they to you?") {
                            currentStep = 3
                            showInput = true
                        }
                    }
                }
            }
        }
    }
    
    func handleSelection(_ selection: String) {
        addUserMessage(selection)
        
        switch currentStep {
        case 1:
            userGender = selection
            saveData()
            addAppMessage("Cool.") {
                addAppMessage("Now the hard part.") {
                    addBigMessage("Who broke you?") {
                        addAppMessage("Their name. First name only.") {
                            currentStep = 2
                            showInput = true
                            isInputFocused = true
                        }
                    }
                }
            }
            
        case 3:
            exGender = selection
            saveData()
            let response = selection.contains("Red Flag") ? "Should've seen it coming. 🚩" : "Noted."
            addAppMessage(response) {
                addAppMessage("How long did this last?") {
                    currentStep = 4
                    showInput = true
                }
            }
            
        case 4:
            duration = selection
            saveData()
            let isLong = selection.contains("y") || selection.contains("3+")
            if isLong {
                addBigMessage("That's a lot of memories.") {
                    addAppMessage("But not all memories deserve to stay.") {
                        addAppMessage("Who ended it?") {
                            currentStep = 5
                            showInput = true
                        }
                    }
                }
            } else {
                addAppMessage("Sometimes the short ones hit the hardest.") {
                    addAppMessage("Who ended it?") {
                        currentStep = 5
                        showInput = true
                    }
                }
            }
            
        case 5:
            initiator = selection
            saveData()
            
            if selection.contains("I did") {
                addBigMessage("You chose yourself.") {
                    addAppMessage("That's power.") {
                        showHealingChart()
                    }
                }
            } else if selection.contains("They did") {
                addBigMessage("Their loss.") {
                    addAppMessage("Not an opinion. A fact.") {
                        showHealingChart()
                    }
                }
            } else {
                addAppMessage("Endings are messy.") {
                    addAppMessage("What matters is what comes next.") {
                        showHealingChart()
                    }
                }
            }
            
        case 6:
            contactStatus = selection
            saveData()
            if selection.contains("No Contact") {
                addBigMessage("Already winning.") {
                    addAppMessage("Social media. Be honest with me.") {
                        currentStep = 7
                        showInput = true
                    }
                }
            } else {
                addAppMessage("We'll fix that.") {
                    addAppMessage("What about social media?\nBe real.") {
                        currentStep = 7
                        showInput = true
                    }
                }
            }
            
        case 7:
            socialStatus = selection
            saveData()
            
            if selection.contains("FBI") || selection.contains("Looking") {
                addAppMessage("I've been there.") {
                    addAppMessage("Here's the truth about healing:") {
                        addAppWidget(.chart(.rollercoaster)) {
                            addAppMessage("It's not a straight line.\nBut you'll get there.") {
                                addAppMessage("How have you been sleeping?") {
                                    currentStep = 8
                                    showInput = true
                                }
                            }
                        }
                    }
                }
            } else {
                addBigMessage("Smart move.") {
                    addAppMessage("But healing isn't linear.") {
                        addAppWidget(.chart(.rollercoaster)) {
                            addAppMessage("Some days will be harder.\nThat's okay.") {
                                addAppMessage("How's your sleep?") {
                                    currentStep = 8
                                    showInput = true
                                }
                            }
                        }
                    }
                }
            }
            
        case 8:
            sleepQuality = selection
            saveData()
            if selection.contains("baby") {
                addAppMessage("Lucky you.") {
                    addAppMessage("How are you feeling right now?\nIn this exact moment?") {
                        currentStep = 9
                        showInput = true
                    }
                }
            } else {
                addAppMessage("Sleep comes back.\nI promise.") {
                    addAppMessage("Right now, in this moment—\nhow do you feel?") {
                        currentStep = 9
                        showInput = true
                    }
                }
            }
            
        case 9:
            mood = selection
            saveData()
            
            addBigMessage("I hear you.") {
                addAppMessage("Here's what I know:") {
                    addAppWidget(.chart(.success)) {
                        addAppMessage("99% of people who commit to this process\nmove on completely.") {
                            addBigMessage("99%.") {
                                addAppMessage("Ready to be one of them?") {
                                    addAppMessage("Sign the pledge.\nMake it official.") {
                                        currentStep = 12
                                        addAppWidget(.contractPrompt)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
        default:
            break
        }
    }
    
    func showHealingChart() {
        addAppMessage("Based on what you've told me...") {
            addAppWidget(.chart(.healing)) {
                addBigMessage("30 days.") {
                    addAppMessage("That's how fast this pain fades\nwhen you commit.") {
                        addAppMessage("Where do you stand with them right now?") {
                            currentStep = 6
                            showInput = true
                        }
                    }
                }
            }
        }
    }
    
    func handleContractSigned() {
        saveData()
        
        // Track tutorial/quiz completion
        AnalyticsManager.shared.trackTutorialCompletion(tutorialId: "intro_quiz", success: true)
        
        router.navigate(.onboarding3)
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

// MARK: - Story Progress Bar

struct StoryProgressBar: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.black.opacity(0.08))
                    .frame(height: 4)
                
                Capsule()
                    .fill(Color.black)
                    .frame(width: geo.size.width * progress, height: 4)
                    .animation(.spring(response: 0.4), value: progress)
            }
        }
        .frame(height: 4)
    }
}

// MARK: - Cinematic Intro

struct CinematicIntro: View {
    let onFinish: () -> Void
    
    @State private var phase = 0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 24) {
                if phase >= 1 {
                    Text("🫀")
                        .font(.system(size: 80))
                        .scaleEffect(phase >= 1 ? 1 : 0.5)
                        .opacity(phase >= 1 ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.6), value: phase)
                }
                
                if phase >= 2 {
                    Text("Let's rebuild.")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                if phase >= 3 {
                    Text("One step at a time.")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .multilineTextAlignment(.center)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { phase = 1 }
            Haptics.feedback(style: .heavy)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.easeOut(duration: 0.5)) { phase = 2 }
                Haptics.feedback(style: .medium)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeOut(duration: 0.5)) { phase = 3 }
                Haptics.feedback(style: .light)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                onFinish()
            }
        }
    }
}

// MARK: - Fullscreen Signing View

struct FullScreenSigningView: View {
    let userName: String
    @Binding var signatureLines: [Line]
    @Binding var currentLine: Line
    @Binding var isSigned: Bool
    let onComplete: () -> Void
    
    @State private var showContent = false
    @State private var localSigned = false
    @State private var showSuccess = false
    
    @State private var transitionPhase = 0
    @State private var flashOpacity: Double = 0
    @State private var shockwaveScale: CGFloat = 0
    @State private var shockwaveOpacity: Double = 1
    @State private var shockwave2Scale: CGFloat = 0
    @State private var shockwave2Opacity: Double = 1
    @State private var shockwave3Scale: CGFloat = 0
    @State private var shockwave3Opacity: Double = 1
    @State private var contractScale: CGFloat = 1
    @State private var contractOpacity: Double = 1
    @State private var glowPulse: CGFloat = 1
    @State private var checkmarkScale: CGFloat = 0
    @State private var checkmarkRotation: Double = -180
    @State private var titleOffset: CGFloat = 50
    @State private var titleOpacity: Double = 0
    @State private var subtitleOffset: CGFloat = 30
    @State private var subtitleOpacity: Double = 0
    @State private var buttonOffset: CGFloat = 100
    @State private var buttonOpacity: Double = 0
    @State private var particleOffset: CGFloat = 0
    @State private var backgroundGradientOpacity: Double = 0
    @State private var ringRotation: Double = 0
    
    var body: some View {
        ZStack {
            backgroundLayer
            signingFormLayer
            shockwaveLayer
            flashLayer
            particlesLayer
            successLayer
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showContent = true
            }
            Haptics.feedback(style: .light)
        }
    }
    
    private var backgroundLayer: some View {
        ZStack {
            Color(hex: "F9F9F9").ignoresSafeArea()
            
            RadialGradient(
                colors: [
                    Color.black.opacity(0.03),
                    Color.clear
                ],
                center: .center,
                startRadius: 0,
                endRadius: UIScreen.main.bounds.width
            )
            .ignoresSafeArea()
            .opacity(backgroundGradientOpacity)
        }
    }
    
    private var flashLayer: some View {
        Color.white
            .ignoresSafeArea()
            .opacity(flashOpacity)
    }
    
    @ViewBuilder
    private var signingFormLayer: some View {
        if !showSuccess {
            SigningFormContent(
                userName: userName,
                signatureLines: $signatureLines,
                currentLine: $currentLine,
                showContent: showContent,
                contractScale: contractScale,
                contractOpacity: contractOpacity,
                onSignComplete: {
                    if !localSigned {
                        localSigned = true
                        isSigned = true
                        triggerMarvelTransition()
                    }
                }
            )
        }
    }
    
    @ViewBuilder
    private var shockwaveLayer: some View {
        if transitionPhase >= 1 {
            ShockwaveEffects(
                shockwaveScale: shockwaveScale,
                shockwaveOpacity: shockwaveOpacity,
                shockwave2Scale: shockwave2Scale,
                shockwave2Opacity: shockwave2Opacity,
                shockwave3Scale: shockwave3Scale,
                shockwave3Opacity: shockwave3Opacity
            )
        }
    }
    
    @ViewBuilder
    private var particlesLayer: some View {
        if transitionPhase >= 1 {
            ParticlesBurst(particleOffset: particleOffset)
        }
    }
    
    @ViewBuilder
    private var successLayer: some View {
        if showSuccess {
            SuccessContent(
                glowPulse: glowPulse,
                ringRotation: ringRotation,
                checkmarkScale: checkmarkScale,
                checkmarkRotation: checkmarkRotation,
                titleOffset: titleOffset,
                titleOpacity: titleOpacity,
                subtitleOffset: subtitleOffset,
                subtitleOpacity: subtitleOpacity,
                buttonOffset: buttonOffset,
                buttonOpacity: buttonOpacity,
                onComplete: onComplete
            )
        }
    }
    
    private func triggerMarvelTransition() {
        Haptics.feedback(style: .heavy)
        transitionPhase = 1
        
        withAnimation(.easeOut(duration: 0.15)) {
            flashOpacity = 0.8
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.easeOut(duration: 0.3)) {
                flashOpacity = 0
            }
        }
        
        withAnimation(.easeOut(duration: 0.25)) {
            contractScale = 0.8
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(.easeOut(duration: 0.3)) {
                contractScale = 0.01
                contractOpacity = 0
            }
        }
        
        withAnimation(.easeOut(duration: 0.8)) {
            shockwaveScale = 3.5
            shockwaveOpacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            Haptics.feedback(style: .medium)
            withAnimation(.easeOut(duration: 0.7)) {
                shockwave2Scale = 3.0
                shockwave2Opacity = 0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeOut(duration: 0.6)) {
                shockwave3Scale = 2.5
                shockwave3Opacity = 0
            }
        }
        
        withAnimation(.easeOut(duration: 1.0)) {
            particleOffset = 200
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            Haptics.notification(type: .success)
            
            withAnimation(.easeOut(duration: 0.5)) {
                backgroundGradientOpacity = 1
            }
            
            showSuccess = true
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.5)) {
                checkmarkScale = 1
                checkmarkRotation = 0
            }
            
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                glowPulse = 1.1
            }
            
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                ringRotation = 360
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            Haptics.feedback(style: .medium)
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                titleOffset = 0
                titleOpacity = 1
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                subtitleOffset = 0
                subtitleOpacity = 1
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            Haptics.feedback(style: .light)
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                buttonOffset = 0
                buttonOpacity = 1
            }
        }
    }
}

// MARK: - Signing Form Content

private struct SigningFormContent: View {
    let userName: String
    @Binding var signatureLines: [Line]
    @Binding var currentLine: Line
    let showContent: Bool
    let contractScale: CGFloat
    let contractOpacity: Double
    let onSignComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            formContent
            Spacer()
            Spacer()
            Color.clear.frame(height: 86)
        }
    }
    
    private var formContent: some View {
        VStack(spacing: 28) {
            headerSection
            pledgeText
            signatureArea
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("NO-CONTACT PLEDGE")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(3)
                .foregroundColor(.secondary)
            
            Text("Sign to commit.")
                .font(.system(size: 36, weight: .black, design: .rounded))
        }
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 20)
    }
    
    private var pledgeText: some View {
        Text("I, \(userName), promise to stop texting, calling, and stalking my ex.\n\nIt's time to focus on me.")
            .font(.system(size: 17, weight: .medium, design: .rounded))
            .multilineTextAlignment(.center)
            .lineSpacing(4)
            .foregroundColor(.secondary)
            .padding(.horizontal, 40)
            .opacity(showContent ? 1 : 0)
    }
    
    private var signatureArea: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 16, y: 6)
            
            if signatureLines.isEmpty && currentLine.points.isEmpty {
                Text("Sign here")
                    .font(.system(size: 28, weight: .light, design: .serif))
                    .italic()
                    .foregroundColor(.black.opacity(0.1))
            }
            
            signatureCanvas
        }
        .frame(height: 160)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Color.black.opacity(0.06), lineWidth: 1)
        )
        .padding(.horizontal, 24)
        .opacity(showContent ? contractOpacity : 0)
        .scaleEffect(showContent ? contractScale : 0.95)
    }
    
    private var signatureCanvas: some View {
        Canvas { context, _ in
            for line in signatureLines {
                var path = Path()
                path.addLines(line.points)
                context.stroke(path, with: .color(.black), lineWidth: 2.5)
            }
            var currentPath = Path()
            currentPath.addLines(currentLine.points)
            context.stroke(currentPath, with: .color(.black), lineWidth: 2.5)
        }
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onChanged { value in
                    currentLine.points.append(value.location)
                }
                .onEnded { _ in
                    signatureLines.append(currentLine)
                    currentLine = Line(points: [])
                    
                    let totalPoints = signatureLines.reduce(0) { $0 + $1.points.count }
                    if totalPoints > 15 {
                        onSignComplete()
                    }
                }
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Shockwave Effects

private struct ShockwaveEffects: View {
    let shockwaveScale: CGFloat
    let shockwaveOpacity: Double
    let shockwave2Scale: CGFloat
    let shockwave2Opacity: Double
    let shockwave3Scale: CGFloat
    let shockwave3Opacity: Double
    
    var body: some View {
        ZStack {
            shockwave1
            shockwave2
            shockwave3
        }
    }
    
    private var shockwave1: some View {
        Circle()
            .stroke(Color.black.opacity(0.6), lineWidth: 4)
            .scaleEffect(shockwaveScale)
            .opacity(shockwaveOpacity)
            .blur(radius: 2)
    }
    
    private var shockwave2: some View {
        Circle()
            .stroke(Color.black.opacity(0.4), lineWidth: 3)
            .scaleEffect(shockwave2Scale)
            .opacity(shockwave2Opacity)
            .blur(radius: 1)
    }
    
    private var shockwave3: some View {
        Circle()
            .stroke(Color.black.opacity(0.2), lineWidth: 2)
            .scaleEffect(shockwave3Scale)
            .opacity(shockwave3Opacity)
    }
}

// MARK: - Particles Burst

private struct ParticlesBurst: View {
    let particleOffset: CGFloat
    
    var body: some View {
        ForEach(0..<12, id: \.self) { i in
            ParticleView(index: i, particleOffset: particleOffset)
        }
    }
}

private struct ParticleView: View {
    let index: Int
    let particleOffset: CGFloat
    
    private var particleSize: CGFloat {
        CGFloat([8, 10, 12, 6, 14, 9, 11, 7, 13, 8, 10, 12][index % 12])
    }
    
    var body: some View {
        let offset = Double(particleOffset)
        let xOffset = CGFloat(cos(Double(index) * .pi / 6) * (50 + offset * 3))
        let yOffset = CGFloat(sin(Double(index) * .pi / 6) * (50 + offset * 3) - offset)
        
        return Circle()
            .fill(Color.black)
            .frame(width: particleSize, height: particleSize)
            .offset(x: xOffset, y: yOffset)
            .opacity(max(0, 1 - offset / 150))
            .blur(radius: offset / 100)
    }
}

// MARK: - Success Content

private struct SuccessContent: View {
    let glowPulse: CGFloat
    let ringRotation: Double
    let checkmarkScale: CGFloat
    let checkmarkRotation: Double
    let titleOffset: CGFloat
    let titleOpacity: Double
    let subtitleOffset: CGFloat
    let subtitleOpacity: Double
    let buttonOffset: CGFloat
    let buttonOpacity: Double
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            checkmarkSection
            Spacer().frame(height: 40)
            titleSection
            Spacer().frame(height: 12)
            subtitleSection
            Spacer()
            Spacer()
            continueButton
        }
    }
    
    private var checkmarkSection: some View {
        ZStack {
            glowRings
            glowCircle
            checkmarkText
        }
    }
    
    private var glowRings: some View {
        ForEach(0..<3, id: \.self) { i in
            GlowRing(index: i, glowPulse: glowPulse, ringRotation: ringRotation)
        }
    }
    
    private var glowCircle: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [Color(hex: "34C759").opacity(0.15), Color.clear],
                    center: .center,
                    startRadius: 20,
                    endRadius: 80
                )
            )
            .frame(width: 160, height: 160)
            .scaleEffect(glowPulse)
    }
    
    private var checkmarkText: some View {
        Text("✓")
            .font(.system(size: 80, weight: .black, design: .rounded))
            .foregroundColor(Color(hex: "34C759"))
            .scaleEffect(checkmarkScale)
            .rotationEffect(.degrees(checkmarkRotation))
            .shadow(color: Color(hex: "34C759").opacity(0.4), radius: 20, x: 0, y: 10)
    }
    
    private var titleSection: some View {
        Text("You're in.")
            .font(.system(size: 48, weight: .black, design: .rounded))
            .foregroundColor(.primary)
            .offset(y: titleOffset)
            .opacity(titleOpacity)
    }
    
    private var subtitleSection: some View {
        Text("Let's build your comeback.")
            .font(.system(size: 18, weight: .semibold, design: .rounded))
            .foregroundColor(.secondary)
            .offset(y: subtitleOffset)
            .opacity(subtitleOpacity)
    }
    
    private var continueButton: some View {
        Button(action: {
            Haptics.feedback(style: .heavy)
            onComplete()
        }) {
            ContinueButtonLabel()
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 50)
        .offset(y: buttonOffset)
        .opacity(buttonOpacity)
    }
}

private struct GlowRing: View {
    let index: Int
    let glowPulse: CGFloat
    let ringRotation: Double
    
    var body: some View {
        Circle()
            .stroke(
                Color.black.opacity(0.15 - Double(index) * 0.04),
                lineWidth: 2
            )
            .frame(width: 120 + CGFloat(index) * 40, height: 120 + CGFloat(index) * 40)
            .scaleEffect(glowPulse)
            .rotationEffect(.degrees(ringRotation + Double(index) * 30))
    }
}

private struct ContinueButtonLabel: View {
    var body: some View {
        Text("Continue")
            .font(.system(size: 18, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.15), radius: 12, y: 6)
    }
}

// MARK: - Chat Bubble

struct OnboardingChatBubble: View {
    let message: OnboardingMessage
    let userName: String
    var onSignTap: (() -> Void)? = nil
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            if message.isUser {
                Spacer(minLength: 60)
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading) {
                switch message.content {
                case .text(let text):
                    Text(text)
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(message.isUser ? .white : .primary)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 14)
                        .background(message.isUser ? Color.black : Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
                    
                case .bigText(let text):
                    Text(text)
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                    
                case .chart(let type):
                    Group {
                        switch type {
                        case .healing: RecoveryTimelineChartView(isVisible: true)
                        case .rollercoaster: EmotionalRollercoasterView(isVisible: true)
                        case .success: SuccessRateChartView(isVisible: true)
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.85)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
                    
                case .contractPrompt:
                    Button(action: {
                        onSignTap?()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "signature")
                                .font(.system(size: 20, weight: .semibold))
                            Text("Sign the Pledge")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(width: UIScreen.main.bounds.width * 0.75)
                        .padding(.vertical, 18)
                        .background(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                    }
                    
                case .cta:
                    EmptyView()
                }
            }
            
            if !message.isUser {
                Spacer(minLength: 40)
            }
        }
        .frame(maxWidth: .infinity, alignment: message.isUser ? .trailing : .leading)
        .padding(.horizontal, 20)
        .transition(.asymmetric(
            insertion: .scale(scale: 0.92, anchor: message.isUser ? .bottomTrailing : .bottomLeading).combined(with: .opacity),
            removal: .opacity
        ))
    }
}

// MARK: - Typing Indicator

struct TypingIndicator: View {
    @State private var animate = false
    
    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3) { i in
                Circle()
                    .fill(Color.black.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .offset(y: animate ? -5 : 0)
                    .animation(
                        Animation.easeInOut(duration: 0.4)
                            .repeatForever(autoreverses: true)
                            .delay(Double(i) * 0.12),
                        value: animate
                    )
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
        .onAppear { animate = true }
    }
}

// MARK: - Input Area

struct InputArea: View {
    let step: Int
    @Binding var inputText: String
    var isFocused: FocusState<Bool>.Binding
    let onSendText: (String) -> Void
    let onSelectOption: (String) -> Void
    
    @State private var localText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            if isTextInputStep {
                HStack(spacing: 12) {
                    TextField("Your answer...", text: $localText)
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .focused(isFocused)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.black.opacity(0.06), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
                        .submitLabel(.send)
                        .onSubmit { send() }
                    
                    Button(action: send) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(localText.isEmpty ? .black.opacity(0.15) : .black)
                            .animation(.easeInOut(duration: 0.2), value: localText.isEmpty)
                    }
                    .disabled(localText.isEmpty)
                }
                .padding(.horizontal, 20)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(optionsForStep, id: \.self) { option in
                            Button(action: {
                                Haptics.feedback(style: .light)
                                onSelectOption(option)
                            }) {
                                Text(option)
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 22)
                                    .padding(.vertical, 14)
                                    .background(Color.black)
                                    .clipShape(Capsule())
                                    .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .padding(.top, 16)
        .padding(.bottom, 34)
    }
    
    func send() {
        if !localText.isEmpty {
            Haptics.feedback(style: .light)
            onSendText(localText)
            localText = ""
        }
    }
    
    var isTextInputStep: Bool {
        return step == 0 || step == 2
    }
    
    var optionsForStep: [String] {
        switch step {
        case 1: return ["Male", "Female", "Other"]
        case 3: return ["Male", "Female", "Red Flag 🚩"]
        case 4: return ["< 3 months", "3-6 months", "6m-1y", "1-3y", "3y+"]
        case 5: return ["I did", "They did", "Mutual", "It's complicated"]
        case 6: return ["No Contact", "Still texting", "Still stalking", "Living together 😬"]
        case 7: return ["Blocked them", "Muted", "Still looking", "FBI Mode 🔍"]
        case 8: return ["Like a baby", "Tossing around", "Dreaming of them", "What's sleep?"]
        case 9: return ["Thriving ✨", "Meh 😐", "Hurting 😢", "Angry 🤬"]
        default: return []
        }
    }
}

// MARK: - Charts

struct RecoveryTimelineChartView: View {
    var isVisible: Bool
    @State private var appear = false
    
    let data = [
        (day: "Now", value: 100),
        (day: "Week 1", value: 80),
        (day: "Week 2", value: 55),
        (day: "Week 3", value: 30),
        (day: "Week 4", value: 8)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Pain Timeline")
                .font(.system(size: 18, weight: .bold, design: .rounded))
            
            Chart {
                ForEach(data, id: \.day) { item in
                    LineMark(
                        x: .value("Time", item.day),
                        y: .value("Pain", appear ? item.value : 100)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.pink, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .lineStyle(StrokeStyle(lineWidth: 4, lineCap: .round))
                    
                    AreaMark(
                        x: .value("Time", item.day),
                        y: .value("Pain", appear ? item.value : 100)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.pink.opacity(0.25), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
            .chartYAxis(.hidden)
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel()
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                }
            }
            .frame(height: 200)
        }
        .padding(24)
        .onAppear {
            withAnimation(.easeOut(duration: 1.2).delay(0.2)) { appear = true }
        }
    }
}

struct EmotionalRollercoasterView: View {
    var isVisible: Bool
    @State private var progress: CGFloat = 0.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("The Reality of Healing")
                .font(.system(size: 18, weight: .bold, design: .rounded))
            
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                
                ZStack {
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: h * 0.7))
                        path.addCurve(
                            to: CGPoint(x: w * 0.35, y: h * 0.2),
                            control1: CGPoint(x: w * 0.15, y: h * 0.9),
                            control2: CGPoint(x: w * 0.25, y: h * 0.1)
                        )
                        path.addCurve(
                            to: CGPoint(x: w * 0.65, y: h * 0.5),
                            control1: CGPoint(x: w * 0.45, y: h * 0.3),
                            control2: CGPoint(x: w * 0.55, y: h * 0.7)
                        )
                        path.addCurve(
                            to: CGPoint(x: w, y: h * 0.15),
                            control1: CGPoint(x: w * 0.75, y: h * 0.3),
                            control2: CGPoint(x: w * 0.9, y: h * 0.1)
                        )
                    }
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: [.orange, .pink, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    
                    if progress > 0.5 {
                        VStack(spacing: 4) {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 12, height: 12)
                                .shadow(color: .black.opacity(0.15), radius: 4)
                            
                            Text("You")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.black)
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                        .position(x: w * 0.5, y: h * 0.45)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            .frame(height: 160)
        }
        .padding(24)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5)) { progress = 1.0 }
        }
    }
}

struct SuccessRateChartView: View {
    var isVisible: Bool
    @State private var animateBar = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Success Rate")
                .font(.system(size: 18, weight: .bold, design: .rounded))
            
            HStack(alignment: .bottom, spacing: 40) {
                VStack(spacing: 8) {
                    Text("40%")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray.opacity(0.15))
                        .frame(width: 60, height: animateBar ? 80 : 0)
                    
                    Text("Alone")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 8) {
                    Text("99%")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                    
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [.pink, .purple],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .frame(width: 60, height: animateBar ? 180 : 0)
                        .shadow(color: .purple.opacity(0.3), radius: 12, x: 0, y: 6)
                    
                    Text("With ExDetox")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 8)
        }
        .padding(24)
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.2)) {
                animateBar = true
            }
        }
    }
}

// MARK: - Helpers

struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

struct Line {
    var points: [CGPoint]
}

#Preview {
    OnboardingView2()
        .environment(Router())
        .environment(UserProfileStore())
}
