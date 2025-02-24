//
//  PlainButtonStyle.swift
//  CSCD-488-Project
//
//  Created by Jacob Lucas on 2/24/25.
//

import SwiftUI

struct PlainButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .frame(height: 45)
                .foregroundColor(Color(.label))
            configuration.label
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(colorScheme == .light ? .white : .black)
        }
        .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}
