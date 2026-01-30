//
//  ButtonStyles.swift
//  MoodCast
//
//  Created by Jacob Lucas on 4/1/25.
//

import SwiftUI

struct CapsuleButtonStyle: ButtonStyle {
    let textColor: Color
    let backgroundColor: Color
    let outlineColor: Color?
    
    init(textColor: Color, backgroundColor: Color, outlineColor: Color? = nil) {
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.outlineColor = outlineColor
    }
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .frame(height: 45)
                .foregroundColor(backgroundColor)
            configuration.label
                .font(.system(size: 19, weight: .semibold))
                .foregroundColor(textColor)
            if let outline = outlineColor {
                RoundedRectangle(cornerRadius: 25)
                    .stroke(lineWidth: 2 / UIScreen.main.scale)
                    .frame(height: 45)
                    .foregroundColor(outline)
            }
        }
        .scaleEffect(configuration.isPressed ? 0.96 : 1)
    }
}

struct ButtonScaleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}
