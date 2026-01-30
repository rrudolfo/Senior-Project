//
//  IntroCards.swift
//  MoodCast
//
//  Created by Jacob Lucas on 4/21/25.
//

import SwiftUI
import CardStack

struct CardWrapper: Identifiable {
    let id = UUID()
    let view: AnyView
}

struct IntroCards: View {
    
    @State var cards: [CardWrapper] = [
        CardWrapper(view: AnyView(OutlineCard(name: "pick_mood"))),
        CardWrapper(view: AnyView(OutlineCard(name: "search_route"))),
        CardWrapper(view: AnyView(OutlineCard(name: "pick_episode")))
    ]
    
    var body: some View {
        CardStack(
            direction: LeftRight.direction,
            data: cards,
            onSwipe: { card, direction in
                print("Swiped \(card) to \(direction)")
            },
            content: { card, direction, isOnTop in
                card.view
            }
        )
    }
}

struct SpotifyCards: View {
    
    @State var cards: [CardWrapper] = [
        CardWrapper(view: AnyView(OutlineCard(name: "pick_mood")))
    ]
    
    var body: some View {
        CardStack(
            direction: LeftRight.direction,
            data: cards,
            onSwipe: { card, direction in
                print("Swiped \(card) to \(direction)")
            },
            content: { card, direction, isOnTop in
                card.view
            }
        )
    }
}

#Preview {
    SpendingCards()
        .padding()
}

struct SpendingCards: View {
    
    @State var cards: [CardWrapper] = [
        CardWrapper(view: AnyView(OutlineCard(name: "pick_mood"))),
        CardWrapper(view: AnyView(OutlineCard(name: "pick_episode"))),
        CardWrapper(view: AnyView(OutlineCard(name: "search_route")))
    ]
    
    var body: some View {
        CardStack(
            direction: LeftRight.direction,
            data: cards,
            onSwipe: { card, direction in
                print("Swiped \(card) to \(direction)")
            },
            content: { card, direction, isOnTop in
                card.view
            }
        )
    }
}

struct OutlineCard: View {
    let name: String
    var body: some View {
        ZStack {
            Image(name)
                .resizable()
                .scaledToFill()
        }
        .frame(
            width: UIScreen.main.bounds.width - 32,
            height: UIScreen.main.bounds.height / 1.8
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(lineWidth: 2)
                .foregroundStyle(Color(.systemGray6))
        }
    }
}
