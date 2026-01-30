//
//  ToggleStyles.swift
//  MoodCast
//
//  Created by Jacob Lucas on 4/19/25.
//

import SwiftUI

struct IconOnlyToggleStyle: ToggleStyle {
    let onImage: Image
    let offImage: Image
    
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            Group {
                if configuration.isOn {
                    onImage
                } else {
                    offImage
                }
            }
            .font(.system(size: 50))
            .foregroundColor(configuration.isOn ? .green : .red)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
