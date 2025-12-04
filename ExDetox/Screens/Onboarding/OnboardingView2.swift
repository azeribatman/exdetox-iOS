import SwiftUI
import Charts

struct OnboardingView2: View {
    // Navigation State
    @State private var currentStep = 0
    
    // User Data Responses
    @State private var name: String = ""
    @State private var selectedGender: String = ""
    @State private var exName: String = ""
    @State private var exGender: String = ""
    @State private var relationshipDuration: String = ""
    @State private var breakupInitiator: String = ""
    @State private var contactStatus: String = ""
    @State private var mood: String = ""
    @State private var sleepQuality: String = ""
    @State private var socialStalking: String = ""
    
    // Signature State
    @State private var signatureLines: [Line] = []
    @State private var currentLine: Line = Line(points: [])
    @State private var isSigned = false
    
    // Total steps for progress calculation
    let totalSteps = 12
    
    // Colors
    let accentGradient = LinearGradient(colors: [.pink, .indigo], startPoint: .leading, endPoint: .trailing)
    
    var body: some View {
        ZStack {
            Color(hex: "F9F9F9").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack(spacing: 12) {
                    if currentStep > 0 {
                        Button(action: previousStep) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                                .padding(10)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 6)
                            
                            Capsule()
                                .fill(accentGradient)
                                .frame(width: (CGFloat(currentStep + 1) / CGFloat(totalSteps)) * geo.size.width, height: 6)
                                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentStep)
                        }
                    }
                    .frame(height: 6)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 10)
                
                // Content Area (Switched from TabView to ZStack for custom non-swipeable navigation)
                ZStack {
                    switch currentStep {
                    case 0:
                        CombinedInputView(
                            isVisible: true,
                            title: "Let's start with you 👤",
                            question: "Who are we helping today?",
                            nameTitle: "Your Name",
                            namePlaceholder: "Name",
                            name: $name,
                            genderTitle: "Your Gender",
                            genderSelection: $selectedGender,
                            genderOptions: ["Male", "Female", "Non-binary"]
                        )
                        .transition(stepTransition)
                    case 1:
                        CombinedInputView(
                            isVisible: true,
                            title: "Now about them... 🙄",
                            question: "Who are we forgetting?",
                            nameTitle: "Their Name",
                            namePlaceholder: "Ex's Name",
                            name: $exName,
                            genderTitle: "Their Gender",
                            genderSelection: $exGender,
                            genderOptions: ["Male", "Female", "Walking Red Flag 🚩"]
                        )
                        .transition(stepTransition)
                    case 2:
                        SimpleSelectionView(
                            isVisible: true,
                            emoji: "⏳",
                            question: "How long did it last?",
                            options: ["< 3 months", "3 - 6 months", "6m - 1 year", "1 - 3 years", "3+ years"],
                            selection: $relationshipDuration
                        )
                        .transition(stepTransition)
                    case 3:
                        SimpleSelectionView(
                            isVisible: true,
                            emoji: "💔",
                            question: "Who pulled the plug?",
                            options: ["I did (Boss move)", "They did (Their loss)", "Mutual (Sure...)", "It's complicated"],
                            selection: $breakupInitiator
                        )
                        .transition(stepTransition)
                    case 4:
                        RecoveryTimelineChartView(isVisible: true)
                            .transition(stepTransition)
                    case 5:
                        SimpleSelectionView(
                            isVisible: true,
                            emoji: "📱",
                            question: "Current status?",
                            options: ["No Contact (Clean streak)", "Texting occasionally", "Stalking silently", "Living together (Oof)"],
                            selection: $contactStatus
                        )
                        .transition(stepTransition)
                    case 6:
                        SimpleSelectionView(
                            isVisible: true,
                            emoji: "🕵️‍♀️",
                            question: "Social Media habits?",
                            options: ["Blocked everywhere", "Muted but looking", "Checking stories daily", "Full FBI investigation"],
                            selection: $socialStalking
                        )
                        .transition(stepTransition)
                    case 7:
                        EmotionalRollercoasterView(isVisible: true)
                            .transition(stepTransition)
                    case 8:
                        SimpleSelectionView(
                            isVisible: true,
                            emoji: "😴",
                            question: "How are you sleeping?",
                            options: ["Like a baby", "Tossing & turning", "Dreaming about them", "What is sleep?"],
                            selection: $sleepQuality
                        )
                        .transition(stepTransition)
                    case 9:
                        SimpleSelectionView(
                            isVisible: true,
                            emoji: "🌡️",
                            question: "Current mood level?",
                            options: ["Thriving ✨", "Okay-ish 😐", "Sad boi hours 😢", "Rage mode 🤬"],
                            selection: $mood
                        )
                        .transition(stepTransition)
                    case 10:
                        SuccessRateChartView(isVisible: true)
                            .transition(stepTransition)
                    case 11:
                        FinalContractView(
                            isVisible: true,
                            name: name,
                            lines: $signatureLines,
                            currentLine: $currentLine,
                            isSigned: $isSigned
                        )
                        .transition(stepTransition)
                    default:
                        EmptyView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .animation(.easeInOut(duration: 0.4), value: currentStep)
                
                // Footer
                VStack {
                    Button(action: nextStep) {
                        HStack {
                            if currentStep == totalSteps - 1 {
                                Text("Seal the Deal")
                                Image(systemName: "checkmark.seal.fill")
                            } else {
                                Text("Continue")
                            }
                        }
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canProceed() ? Color.black : Color.gray.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: canProceed() ? .black.opacity(0.1) : .clear, radius: 10, x: 0, y: 5)
                    }
                    .disabled(!canProceed())
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
            }
            
            if isSigned && currentStep == totalSteps - 1 {
                ConfettiView()
                    .ignoresSafeArea()
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    var stepTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }
    
    // Logic
    func nextStep() {
        withAnimation {
            if currentStep < totalSteps - 1 {
                currentStep += 1
            } else {

            }
        }
    }
    
    func previousStep() {
        withAnimation {
            if currentStep > 0 {
                currentStep -= 1
            }
        }
    }
    
    func canProceed() -> Bool {
        switch currentStep {
        case 0: return !name.isEmpty && !selectedGender.isEmpty
        case 1: return !exName.isEmpty && !exGender.isEmpty
        case 2: return !relationshipDuration.isEmpty
        case 3: return !breakupInitiator.isEmpty
        case 5: return !contactStatus.isEmpty
        case 6: return !socialStalking.isEmpty
        case 8: return !sleepQuality.isEmpty
        case 9: return !mood.isEmpty
        case 11: return isSigned
        default: return true
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Animated Subviews

struct CombinedInputView: View {
    var isVisible: Bool
    let title: String
    let question: String
    let nameTitle: String
    let namePlaceholder: String
    @Binding var name: String
    let genderTitle: String
    @Binding var genderSelection: String
    let genderOptions: [String]
    
    @State private var internalState = false
    
    var show: Bool {
        isVisible && internalState
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer(minLength: 40)
                
                // Adjusted Title Visuals
                Text(title)
                    .font(.caption) // Smaller font
                    .fontWeight(.bold)
                    .foregroundStyle(.tertiary) // Much lighter color
                    .textCase(.uppercase)
                    .tracking(2)
                    .opacity(show ? 1 : 0)
                    .offset(y: show ? 0 : 10)
                    .animation(.easeOut(duration: 0.5).delay(0.1), value: show)
                
                Text(question)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    .opacity(show ? 1 : 0)
                    .scaleEffect(show ? 1 : 0.95)
                    .animation(.easeOut(duration: 0.5).delay(0.05), value: show) // Slightly faster than title
                
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(nameTitle)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                            .padding(.leading, 4)
                        
                        TextField(namePlaceholder, text: $name)
                            .font(.title3)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    .opacity(show ? 1 : 0)
                    .offset(y: show ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.3), value: show)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(genderTitle)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                            .padding(.leading, 4)
                        
                        // Vertical Layout for Gender to accommodate long text like "Walking Red Flag"
                        VStack(spacing: 10) {
                            ForEach(Array(genderOptions.enumerated()), id: \.element) { index, option in
                                Button(action: { withAnimation { genderSelection = option } }) {
                                    Text(option)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(genderSelection == option ? .white : .primary)
                                        .padding(.vertical, 12)
                                        .frame(maxWidth: .infinity)
                                        .background(genderSelection == option ? Color.black : Color.white)
                                        .cornerRadius(12)
                                        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(genderSelection == option ? Color.clear : Color.gray.opacity(0.1), lineWidth: 1)
                                        )
                                }
                                .scaleEffect(show ? 1 : 0.8)
                                .opacity(show ? 1 : 0)
                                .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.4 + Double(index) * 0.1), value: show)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer(minLength: 40)
            }
            .frame(minHeight: UIScreen.main.bounds.height * 0.6) // Ensure scrolling works if needed but centers mostly
        }
        .onAppear {
            internalState = true
        }
    }
}

struct SimpleSelectionView: View {
    var isVisible: Bool
    let emoji: String
    let question: String
    let options: [String]
    @Binding var selection: String
    
    @State private var internalState = false
    
    var show: Bool {
        isVisible && internalState
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer(minLength: 40)
                
                Text(emoji)
                    .font(.system(size: 64))
                    .scaleEffect(show ? 1 : 0.5)
                    .opacity(show ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1), value: show)
                
                Text(question)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .opacity(show ? 1 : 0)
                    .offset(y: show ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.2), value: show)
                
                VStack(spacing: 12) {
                    ForEach(Array(options.enumerated()), id: \.element) { index, option in
                        Button(action: { withAnimation { selection = option } }) {
                            HStack {
                                Text(option)
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(selection == option ? .white : .primary)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                                
                                if selection == option {
                                    Image(systemName: "checkmark")
                                        .font(.subheadline.bold())
                                        .foregroundColor(.white)
                                }
                            }
                            .padding()
                            .background(selection == option ? Color.black : Color.white)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                        .offset(x: show ? 0 : (index % 2 == 0 ? -50 : 50))
                        .opacity(show ? 1 : 0)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.8)
                            .delay(0.3 + Double(index) * 0.1),
                            value: show
                        )
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer(minLength: 40)
            }
            .frame(minHeight: UIScreen.main.bounds.height * 0.6)
        }
        .onAppear {
            internalState = true
        }
    }
}

struct RecoveryTimelineChartView: View {
    var isVisible: Bool
    
    let data = [
        (day: "Day 1", value: 100),
        (day: "Day 7", value: 80),
        (day: "Day 14", value: 60),
        (day: "Day 30", value: 20)
    ]
    
    @State private var internalState = false
    
    var show: Bool {
        isVisible && internalState
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer(minLength: 40)
                
                VStack(spacing: 8) {
                    Text("📈")
                        .font(.largeTitle)
                        .scaleEffect(show ? 1 : 0.5)
                        .opacity(show ? 1 : 0)
                        .animation(.spring().delay(0.1), value: show)
                        
                    Text("The Healing Trajectory")
                        .font(.title2)
                        .fontWeight(.bold)
                        .opacity(show ? 1 : 0)
                        .animation(.easeOut.delay(0.2), value: show)
                        
                    Text("Stick with us, and the pain drops.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .opacity(show ? 1 : 0)
                        .animation(.easeOut.delay(0.3), value: show)
                }
                
                Chart {
                    ForEach(data, id: \.day) { item in
                        LineMark(
                            x: .value("Time", item.day),
                            y: .value("Pain Level", show ? item.value : 0)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(LinearGradient(colors: [.pink, .indigo], startPoint: .top, endPoint: .bottom))
                        .lineStyle(StrokeStyle(lineWidth: 4))
                        
                        AreaMark(
                            x: .value("Time", item.day),
                            y: .value("Pain Level", show ? item.value : 0)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(
                            LinearGradient(colors: [.pink.opacity(0.3), .indigo.opacity(0.0)], startPoint: .top, endPoint: .bottom)
                        )
                    }
                }
                .frame(height: 250)
                .padding(24)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 24)
                .animation(.easeInOut(duration: 1.5).delay(0.2), value: show)
                
                Text("Based on thousands of users who didn't text back.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .opacity(show ? 1 : 0)
                    .animation(.easeOut.delay(1.0), value: show)
                
                Spacer(minLength: 40)
            }
            .frame(minHeight: UIScreen.main.bounds.height * 0.6)
        }
        .onAppear {
            internalState = true
        }
    }
}

struct EmotionalRollercoasterView: View {
    var isVisible: Bool
    @State private var showDot = false
    @State private var internalState = false
    
    var show: Bool {
        isVisible && internalState
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer(minLength: 40)
                
                VStack(spacing: 8) {
                    Text("🎢")
                        .font(.largeTitle)
                        .scaleEffect(show ? 1 : 0.5)
                        .animation(.spring().delay(0.1), value: show)
                    Text("It's not linear")
                        .font(.title2)
                        .fontWeight(.bold)
                        .opacity(show ? 1 : 0)
                        .animation(.easeOut.delay(0.2), value: show)
                    Text("Ups and downs are normal.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .opacity(show ? 1 : 0)
                        .animation(.easeOut.delay(0.3), value: show)
                }
                
                ZStack {
                    Color.white
                    
                    Path { path in
                        path.move(to: CGPoint(x: 20, y: 150))
                        path.addCurve(
                            to: CGPoint(x: 300, y: 50),
                            control1: CGPoint(x: 100, y: 0),
                            control2: CGPoint(x: 200, y: 200)
                        )
                    }
                    .trim(from: 0, to: show ? 1 : 0)
                    .stroke(LinearGradient(colors: [.orange, .pink], startPoint: .leading, endPoint: .trailing), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .animation(.easeInOut(duration: 2.0).delay(0.2), value: show)
                    
                    if showDot {
                        Circle()
                            .fill(Color.pink)
                            .frame(width: 12, height: 12)
                            .position(x: 150, y: 100)
                            .overlay(
                                Text("You are here")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .padding(6)
                                    .background(Color.black)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                    .offset(y: -25)
                            )
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 24)
                .onChange(of: show) { newValue in
                    if newValue {
                        showDot = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation(.spring()) {
                                showDot = true
                            }
                        }
                    }
                }
                
                Spacer(minLength: 40)
            }
            .frame(minHeight: UIScreen.main.bounds.height * 0.6)
        }
        .onAppear {
            internalState = true
        }
    }
}

struct SuccessRateChartView: View {
    var isVisible: Bool
    
    @State private var internalState = false
    
    var show: Bool {
        isVisible && internalState
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer(minLength: 40)
                
                VStack(spacing: 8) {
                    Text("🏆")
                        .font(.largeTitle)
                        .scaleEffect(show ? 1 : 0.5)
                        .animation(.spring().delay(0.1), value: show)
                    Text("Success Rate")
                        .font(.title2)
                        .fontWeight(.bold)
                        .opacity(show ? 1 : 0)
                        .animation(.easeOut.delay(0.2), value: show)
                    Text("People who finish the 30-day detox.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .opacity(show ? 1 : 0)
                        .animation(.easeOut.delay(0.3), value: show)
                }
                
                HStack(alignment: .bottom, spacing: 20) {
                    VStack {
                        Text("Others")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .opacity(show ? 1 : 0)
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 40, height: show ? 100 : 0)
                            .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2), value: show)
                        Text("40%")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .opacity(show ? 1 : 0)
                            .animation(.easeOut.delay(0.4), value: show)
                    }
                    
                    VStack {
                        Text("You")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .opacity(show ? 1 : 0)
                        RoundedRectangle(cornerRadius: 8)
                            .fill(LinearGradient(colors: [.pink, .indigo], startPoint: .bottom, endPoint: .top))
                            .frame(width: 40, height: show ? 180 : 0)
                            .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.4), value: show)
                        Text("99%")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .opacity(show ? 1 : 0)
                            .animation(.easeOut.delay(0.6), value: show)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(32)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 24)
                
                Spacer(minLength: 40)
            }
            .frame(minHeight: UIScreen.main.bounds.height * 0.6)
        }
        .onAppear {
            internalState = true
        }
    }
}

struct FinalContractView: View {
    var isVisible: Bool
    let name: String
    @Binding var lines: [Line]
    @Binding var currentLine: Line
    @Binding var isSigned: Bool
    
    @State private var animatePulse = false
    @State private var internalState = false
    
    var show: Bool {
        isVisible && internalState
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer(minLength: 40)
                
                Text("📜")
                    .font(.system(size: 64))
                    .scaleEffect(isSigned ? 1.2 : 1.0)
                    .scaleEffect(show ? 1 : 0.5)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: show)
                
                VStack(spacing: 12) {
                    Text("THE NO-CONTACT CONTRACT")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .tracking(2)
                        .opacity(show ? 1 : 0)
                        .offset(y: show ? 0 : 10)
                        .animation(.easeOut.delay(0.2), value: show)
                    
                    Text("I, \(name.isEmpty ? "User" : name), hereby promise not to text, call, or stalk my ex.")
                        .font(.title3)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .lineSpacing(4)
                        .opacity(show ? 1 : 0)
                        .scaleEffect(show ? 1 : 0.95)
                        .animation(.easeOut.delay(0.3), value: show)
                }
                
                // Signature Pad
                VStack(alignment: .leading, spacing: 8) {
                    Text("Sign here to commit:")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 8)
                        .opacity(show ? 1 : 0)
                        .animation(.easeOut.delay(0.4), value: show)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        
                        // Signature Canvas
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
                                self.isSigned = true
                            })
                        )
                        
                        if lines.isEmpty && currentLine.points.isEmpty {
                            Text("Sign Here")
                                .font(.largeTitle)
                                .foregroundColor(.gray.opacity(0.2))
                                .rotationEffect(.degrees(-10))
                                .scaleEffect(animatePulse ? 1.1 : 1.0)
                                .onAppear {
                                    withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                                        animatePulse = true
                                    }
                                }
                        }
                    }
                    .frame(height: 200)
                    .opacity(show ? 1 : 0)
                    .offset(y: show ? 0 : 20)
                    .animation(.spring().delay(0.5), value: show)
                    
                    HStack {
                        Spacer()
                        Button("Clear") {
                            lines = []
                            isSigned = false
                        }
                        .font(.caption)
                        .foregroundColor(.red)
                        .opacity(lines.isEmpty ? 0 : 1)
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer(minLength: 40)
            }
            .frame(minHeight: UIScreen.main.bounds.height * 0.6)
        }
        .onAppear {
            internalState = true
        }
    }
}

struct ConfettiView: View {
    @State private var animate = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<50) { index in
                    ConfettiPiece(position: CGPoint(
                        x: CGFloat.random(in: 0...geo.size.width),
                        y: animate ? geo.size.height + 50 : -50
                    ), color: [Color.pink, Color.indigo, Color.orange].randomElement()!)
                    .animation(
                        Animation.linear(duration: Double.random(in: 2...4))
                            .repeatForever(autoreverses: false)
                            .delay(Double.random(in: 0...2)),
                        value: animate
                    )
                }
            }
            .onAppear {
                animate = true
            }
        }
    }
}

struct ConfettiPiece: View {
    var position: CGPoint
    var color: Color
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 8, height: 8)
            .position(position)
    }
}

struct Line {
    var points: [CGPoint]
}

#Preview {
    OnboardingView2()
}
