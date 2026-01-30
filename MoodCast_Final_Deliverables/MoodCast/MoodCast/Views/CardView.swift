//
//  CardView.swift
//  MoodCast
//
//  Created by Jacob Lucas on 4/6/25.
//

import SwiftUI
import AppIntents

struct SwipeableCardsView: View {

    @ObservedObject var model: Model
    @StateObject var viewModel: MainViewModel
    
    @State var showMapView: Bool = false
    @State private var dragState = CGSize.zero
    @State private var cardRotation: Double = 0
    
    @State private var progress: CGFloat = 0
    
    let width = UIScreen.main.bounds.width - 32
    let height = UIScreen.main.bounds.height / 1.55
    
    @State var showPodcastView: Bool = false
    @Environment(\.colorScheme) var colorScheme
    
    private let rotationFactor: Double = 35.0
    private let swipeThreshold: CGFloat = 100.0
    
    var action: (Model) -> Void
    
    class Model: ObservableObject {
        private var originalCards: [EpisodeModel]
        
        @Published var unswipedCards: [EpisodeModel]
        @Published var swipedCards: [EpisodeModel]
        
        
        init(cards: [EpisodeModel], viewModel: MainViewModel) {
            self.originalCards = cards
            self.unswipedCards = cards
            self.swipedCards = []
        }
        
        func removeTopCard(direction: EpisodeModel.SwipeDirection) {
            if !unswipedCards.isEmpty {
                var card = unswipedCards.removeFirst()
                card.swipeDirection = direction
                swipedCards.append(card)
            }
        }
        
        func updateTopCardSwipeDirection(_ direction: EpisodeModel.SwipeDirection) {
            if !unswipedCards.isEmpty {
                unswipedCards[0].swipeDirection = direction
            }
        }
        
        func reset() {
            unswipedCards = originalCards
            swipedCards = []
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            if model.unswipedCards.isEmpty && model.swipedCards.isEmpty {
                defaultCard
            } else if model.unswipedCards.isEmpty {
                defaultCard
            } else {
                ZStack(alignment: .bottom) {
//                    let cards = model.unswipedCards
//                    var filteredCards = cards.filter {
//                        !viewModel.blockedList.contains($0.episodeId ?? "")
//                    }
//
                    ForEach(model.unswipedCards.reversed()) { card in
                        let isTop = card == model.unswipedCards.first
                        let isSecond = card == model.unswipedCards.dropFirst().first
                        
                        CardView(
                            episode: card,
                            size: geometry.size,
                            dragOffset: dragState,
                            isTopCard: isTop,
                            isSecondCard: isSecond,
                            viewModel: viewModel
                        )
                        .offset(x: isTop ? dragState.width : 0)
                        .rotationEffect(.degrees(isTop ? Double(dragState.width) / rotationFactor : 0))
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    self.dragState = gesture.translation
                                    self.cardRotation = Double(gesture.translation.width) / rotationFactor
                                }
                                .onEnded { _ in
                                    if abs(self.dragState.width) > swipeThreshold {
                                        let swipeDirection: EpisodeModel.SwipeDirection = self.dragState.width > 0 ? .right : .left
                                        model.updateTopCardSwipeDirection(swipeDirection)
                                        
                                        withAnimation(.easeOut(duration: 0.5)) {
                                            self.dragState.width = self.dragState.width > 0 ? 1000 : -1000
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            self.model.removeTopCard(direction: swipeDirection)
                                            self.dragState = .zero
                                        }
                                    } else {
                                        withAnimation(.spring()) {
                                            self.dragState = .zero
                                            self.cardRotation = 0
                                        }
                                    }
                                }
                        )
                        .animation(.easeInOut, value: dragState)
                        .fullScreenCover(isPresented: $showPodcastView) {
                            if let episode = model.unswipedCards.reversed().first {
                                PodcastView(episode: episode, mainViewModel: viewModel)
                            }
                        }
                        
                        if isTop {
                            StackControls(buttons: [
                                ControlButton(systemName: "info", baseColor: .blue, size: 40, yOffset: 0) {
                                    self.showPodcastView.toggle()
                                },
                                ControlButton(systemName: "xmark", baseColor: .primary, size: 65, yOffset: 0) {
                                    withAnimation(.easeOut(duration: 0.5)) {
                                        self.dragState.width = -1000
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        self.model.removeTopCard(direction: .left)
                                        self.dragState = .zero
                                        action(model)
                                    }
                                },
                                ControlButton(systemName: "heart.fill", baseColor: .pink, size: 65, yOffset: 2) {
                                    viewModel.handleRightSwipe(for: card)
                                    withAnimation(.easeOut(duration: 0.5)) {
                                        self.dragState.width = 1000
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        self.model.removeTopCard(direction: .right)
                                        self.dragState = .zero
                                        action(model)
                                    }
                                },
                                ControlButton(systemName: "nosign", baseColor: .red, size: 40, yOffset: 0) {
                                    withAnimation(.easeOut(duration: 0.5)) {
                                        self.dragState.width = 1000
                                        self.addToBlockList(episode: card)
                                    }
                                }
                            ])
                            .padding(.bottom, 3)
                        }
                    }
                }
                .offset(x: -16)
            }
        }
    }
    
    func addToBlockList(episode: EpisodeModel) {
        guard let id = episode.episodeId else {
            print("Unable to unwrap episode id.")
            return
        }
        
        let dataService = DataService.shared
        dataService.saveBlockedEpisode(episode: episode)
        viewModel.blockedList.append(id)
    }
    
    struct Mood: Identifiable {
        let id = UUID()
        let emoji: String
        let title: String
    }
    
    @State private var showMoodPicker = false
    @State private var selectedMoodIndex = 0
    
    private let moods: [Mood] = [
        .init(emoji: "😀", title: "Happy"),
        .init(emoji: "☹️", title: "Sad"),
        .init(emoji: "😠", title: "Angry"),
        .init(emoji: "😨", title: "Scared"),
        .init(emoji: "💸", title: "Investing"),
        .init(emoji: "🚀", title: "Motivation"),
        .init(emoji: "📸", title: "Nostalgia"),
        .init(emoji: "⚛️", title: "Science"),
        .init(emoji: "🌊", title: "Calming")
    ]
    
    private var defaultCard: some View {
        VStack {
            if viewModel.showEmojiSelection {
                moodPicker
            } else {
                ZStack {
                    if viewModel.isLoading {
                        RoundedBorderSegment(cornerRadius: 16)
                            .trim(from: progress, to: progress + 0.04)
                            .stroke(Color.blue, lineWidth: 3)
                            .frame(width: width, height: height)
                            .blur(radius: 1)
                            .shadow(color: .blue, radius: 20)
                            .onAppear {
                                withAnimation(.linear(duration: 1.6).repeatForever(autoreverses: false)) {
                                    progress = 1
                                }
                            }
                            .onDisappear {
                                progress = 0
                            }
                    }
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundStyle(colorScheme == .light ? .white : .black)
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(lineWidth: 2)
                        .foregroundStyle(Color(.systemGray6))
                }
                .frame(
                    width: UIScreen.main.bounds.width - 32,
                    height: UIScreen.main.bounds.height / 1.55
                )
                .overlay {
                    VStack(spacing: 6) {
                        Text("No Podcasts")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text("Press the + to generate a new\n list of podcasts.")
                            .font(.subheadline)
                            .fontWeight(.light)
                            .foregroundStyle(Color(.systemGray))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)
                }
                .overlay(alignment: .bottom) {
                    Button {
                        if viewModel.isCarRide {
                            showMapView.toggle()
                        } else {
                            viewModel.showEmojiSelection = true
                        }
                    } label: {
                        VStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                HStack(spacing: 12) {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Generate")
                                        .fontWeight(.medium)
                                }
                            }
                        }
                        .font(.title3)
                        .padding(12)
                        .padding(.trailing, viewModel.isLoading ? 0 : 8)
                        .foregroundStyle(.white)
                        .background {
                            Capsule()
                                .foregroundStyle(Color.accentColor)
                            Capsule()
                                .inset(by: 1)
                                .stroke(lineWidth: 2)
                                .foregroundStyle(.white.opacity(0.4))
                        }
                        .padding()
                    }
                    .buttonStyle(ButtonScaleStyle())
                    .sheet(isPresented: $showMapView) {
                        ETEView(
                            showMapView: $showMapView,
                            showEmojiSelection: $viewModel.showEmojiSelection
                        )
                        .presentationCornerRadius(30)
                    }
                }
            }
        }
    }
    
    private var moodPicker: some View {
        VStack(spacing: 0) {
            let columns = [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ]
            
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(moods.indices, id: \.self) { idx in
                    Button {
                        selectedMoodIndex = idx
                    } label: {
                        VStack(spacing: 8) {
                            Text(moods[idx].emoji)
                                .font(.system(size: 40))
                            Text(moods[idx].title)
                                .font(.system(size: 13, weight: .semibold))
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            ZStack {
                                if selectedMoodIndex == idx {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.accentColor)
                                    RoundedRectangle(cornerRadius: 10)
                                        .inset(by: 1)
                                        .stroke(lineWidth: 2)
                                        .foregroundStyle(.white.opacity(0.4))
                                } else {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(.systemGray6))
                                }
                            }
                        )
                        .foregroundColor(selectedMoodIndex == idx ? .white : .primary)
                    }
                    .buttonStyle(ButtonScaleStyle())
                    .animation(.easeInOut, value: selectedMoodIndex)
                }
            }
            .padding()
            Spacer()
            
            HStack {
                Button {
                    viewModel.generateNewEpisodes(mood: moods[selectedMoodIndex].title)
                } label: {
                    VStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Select Mood")
                                .fontWeight(.medium)
                        }
                    }
                    .font(.title3)
                    .padding(12)
                    .padding(.horizontal, viewModel.isLoading ? 0 : 8)
                    .foregroundStyle(.white)
                    .background {
                        Capsule()
                            .foregroundStyle(Color.accentColor)
                        Capsule()
                            .inset(by: 1)
                            .stroke(lineWidth: 2)
                            .foregroundStyle(.white.opacity(0.4))
                    }
                    .padding()
                }
                .buttonStyle(ButtonScaleStyle())
            }
        }
        .frame(
            width: UIScreen.main.bounds.width - 32,
            height: UIScreen.main.bounds.height / 1.55
        )
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .foregroundStyle(colorScheme == .light ? .white : .black)
                RoundedRectangle(cornerRadius: 16)
                    .stroke(lineWidth: 2)
                    .foregroundStyle(Color(.systemGray6))
            }
        }
    }
}

struct RoundedBorderSegment: Shape {
    var cornerRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRoundedRect(in: rect, cornerSize: CGSize(width: cornerRadius, height: cornerRadius))
        return path
    }
}

struct CardView: View {
    enum SwipeDirection {
        case left, right, none
    }
    
    struct Model: Identifiable, Equatable {
        let id = UUID()
        let text: String
        var swipeDirection: SwipeDirection = .none
    }
    
    var episode: EpisodeModel
    var size: CGSize
    var dragOffset: CGSize
    var isTopCard: Bool
    var isSecondCard: Bool
    
    @State var isPresentingPodcastView: Bool = false
    @StateObject var viewModel: MainViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            PodcastCard(episode: episode)
            getCardOverlay()
        }
        .frame(
            width: UIScreen.main.bounds.width - 32,
            height: UIScreen.main.bounds.height / 1.55
        )
        .scaleEffect(isTopCard ? 1.0 : 0.95)
        .animation(.easeOut, value: dragOffset)
        .sheet(isPresented: $isPresentingPodcastView) {
            PodcastView(episode: episode, mainViewModel: viewModel)
        }
    }
    
    private func triggerHaptics() {
        let hapticsManager = HapticsFeedbackManager.shared
        hapticsManager.triggerVibration()
    }
    
    private func getCardOverlay() -> some View {
        VStack {
            if (isTopCard) {
                HStack {
                    if dragOffset.width < 0 {
                        Spacer()
                    }
                    if dragOffset.width > 0 {
                        HStack {
                            Text("FAVORITE")
                                .foregroundStyle(.white)
                            Text("😍")
                                .font(.title)
                        }
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 16)
                                .foregroundStyle(.green.opacity(0.8))
                        }
                        .padding()
                        .rotationEffect(Angle(degrees: -15))
                        .offset(x: -25)
                    } else if dragOffset.width < 0 {
                        HStack {
                            Text("👋")
                                .font(.title)
                            Text("NOPE")
                                .foregroundStyle(.white)
                        }
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 16)
                                .foregroundStyle(.red.opacity(0.8))
                        }
                        .padding()
                        .rotationEffect(Angle(degrees: 15))
                        .offset(x: 25)
                    }
                    if dragOffset.width > 0 {
                        Spacer()
                    }
                }
                Spacer()
            }
        }
    }
}

struct PodcastCard: View {
    let episode: EpisodeModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if let uiImage = episode.image {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width - 32)
                    .blur(radius: 20)
                    .overlay(Color.black.opacity(0.5))
                    .overlay(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .fill(colorScheme == .light ? .white : Color(.systemGray6))
            }
            RoundedRectangle(cornerRadius: 20)
                .stroke(lineWidth: 2)
                .foregroundStyle(Color(.systemGray5))
            
            VStack(alignment: .leading, spacing: 12) {
                if let image = episode.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 320)
                        .frame(maxWidth: UIScreen.main.bounds.width - 32)
                        .clipShape(
                            MessageRoundedCorners(
                                topLeading: 14,
                                topTrailing: 14,
                                bottomLeading: 5,
                                bottomTrailing: 5)
                        )
                        .padding(8)
                } else {
                    Rectangle()
                        .frame(height: 320)
                        .clipShape(
                            MessageRoundedCorners(
                                topLeading: 14,
                                topTrailing: 14,
                                bottomLeading: 5,
                                bottomTrailing: 5)
                        )
                        .padding(8)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        if let name = episode.name {
                            Text(name)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                        }
                        Spacer()
                    }
                    
                    if let desc = episode.description {
                        Text(desc)
                            .lineSpacing(6)
                            .font(.subheadline)
                            .fontWeight(.light)
                            .lineLimit(3)
                            .padding(.trailing)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
                .padding(.horizontal)
                .foregroundStyle(.white)
                
                Spacer()
            }
        }
    }
}

#Preview {
    let model = SwipeableCardsView.Model(
        cards: [],
        viewModel: MainViewModel()
    )
    SwipeableCardsView(model: model, viewModel: MainViewModel()) { _ in }
}

struct MessageRoundedCorners: Shape {
    var topLeading: CGFloat = 0.0
    var topTrailing: CGFloat = 0.0
    var bottomLeading: CGFloat = 0.0
    var bottomTrailing: CGFloat = 0.0
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let w = rect.size.width
        let h = rect.size.height
        
        let tr = min(min(self.topTrailing, h/2), w/2)
        let tl = min(min(self.topLeading, h/2), w/2)
        let bl = min(min(self.bottomLeading, h/2), w/2)
        let br = min(min(self.bottomTrailing, h/2), w/2)
        
        path.move(to: CGPoint(x: w / 2.0, y: 0))
        path.addLine(to: CGPoint(x: w - tr, y: 0))
        path.addArc(center: CGPoint(x: w - tr, y: tr), radius: tr,
                    startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
        
        path.addLine(to: CGPoint(x: w, y: h - br))
        path.addArc(center: CGPoint(x: w - br, y: h - br), radius: br,
                    startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
        
        path.addLine(to: CGPoint(x: bl, y: h))
        path.addArc(center: CGPoint(x: bl, y: h - bl), radius: bl,
                    startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
        
        path.addLine(to: CGPoint(x: 0, y: tl))
        path.addArc(center: CGPoint(x: tl, y: tl), radius: tl,
                    startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
        path.closeSubpath()
        
        return path
    }
}

class BlockedEpisodesManager {
    private let fileName = "blockedEpisodeIds.json"
    
    private var fileURL: URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[0].appendingPathComponent(fileName)
    }
    
    func loadBlockedEpisodeIds() -> Set<String> {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode(Set<String>.self, from: data)
        else {
            return []
        }
        return decoded
    }
    
    func saveBlockedEpisodeIds(_ ids: Set<String>) {
        if let data = try? JSONEncoder().encode(ids) {
            try? data.write(to: fileURL)
        }
    }
    
    func addBlockedEpisode(id: String) {
        var current = loadBlockedEpisodeIds()
        current.insert(id)
        saveBlockedEpisodeIds(current)
    }
    
    func removeBlockedEpisode(id: String) {
        var current = loadBlockedEpisodeIds()
        current.remove(id)
        saveBlockedEpisodeIds(current)
    }
}
