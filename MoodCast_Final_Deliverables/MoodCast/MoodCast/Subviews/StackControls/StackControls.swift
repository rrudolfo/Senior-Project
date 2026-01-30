//
//  StackControls.swift
//  MoodCast
//
//  Created by Jacob Lucas on 4/26/25.
//

import SwiftUI

struct StackControls: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var pressedButton: String? = nil
    
    var buttons: [ControlButton]

    var body: some View {
        content
    }
}

struct ControlButton: Identifiable {
    let id = UUID()
    let systemName: String
    let baseColor: Color
    let size: CGFloat
    let yOffset: CGFloat
    let action: () -> Void
}

#Preview {
    StackControls(buttons: [
        ControlButton(systemName: "info", baseColor: .blue, size: 40, yOffset: 0) { print("Info pressed") },
        ControlButton(systemName: "xmark", baseColor: .primary, size: 65, yOffset: 0) { print("X pressed") },
        ControlButton(systemName: "heart.fill", baseColor: .pink, size: 65, yOffset: 2) { print("Heart pressed") },
        ControlButton(systemName: "star.fill", baseColor: .yellow, size: 40, yOffset: 0) { print("Star pressed") }
    ])
}

extension StackControls {
    private var content: some View {
        HStack {
            Spacer(minLength: 0)
            
            ForEach(buttons) { button in
                controlButton(button: button)
                Spacer(minLength: 0)
            }
        }
        .padding(.bottom, 12)
    }
    
    private func controlButton(button: ControlButton) -> some View {
        Button {
            pressedButton = button.systemName
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            button.action()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                pressedButton = nil
            }
        } label: {
            ZStack {
                Circle()
                    .fill(pressedButton == button.systemName ? button.baseColor : (colorScheme == .light ? .white : Color(.systemGray6)))
                    .frame(width: button.size, height: button.size)
                    .overlay(
                        Circle()
                            .stroke(lineWidth: 2)
                            .foregroundStyle(Color(.systemGray5))
                    )
                
                Image(systemName: button.systemName)
                    .font(.system(size: button.size / 2, weight: .semibold))
                    .foregroundStyle(pressedButton == button.systemName ? Color.white : button.baseColor)
                    .offset(y: button.yOffset)
            }
            .scaleEffect(pressedButton == button.systemName ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: pressedButton == button.systemName)
        }
        .buttonStyle(.plain)
    }
}
