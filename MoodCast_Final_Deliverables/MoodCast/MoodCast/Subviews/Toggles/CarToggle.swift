//
//  CarToggle.swift
//  MoodCast
//
//  Created by Jacob Lucas on 4/19/25.
//

import SwiftUI

struct CarToggle: View {
    @Binding var isCarRide: Bool
    @Binding var emojiSelection: Bool
    var body: some View {
        HStack(spacing: 10) {
            Toggle("", isOn: $isCarRide)
                .labelsHidden()
                .onChange(of: isCarRide) { (_, newValue) in
                    if newValue {
                        emojiSelection = false
                    }
                }
            
            Text("🚙")
                .opacity(isCarRide ? 1.0 : 0.5)
                .font(.title)
                .animation(.easeInOut, value: isCarRide)
        }
    }
}

#Preview {
    CarToggle(
        isCarRide: .constant(false),
        emojiSelection: .constant(false)
    )
}
