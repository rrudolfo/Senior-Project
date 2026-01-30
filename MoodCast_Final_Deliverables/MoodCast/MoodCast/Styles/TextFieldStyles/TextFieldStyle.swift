//
//  TextFieldStyle.swift
//  MoodCast
//
//  Created by Jacob Lucas on 4/1/25.
//

import SwiftUI

struct CapsuleTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .frame(height: 45)
                .foregroundStyle(Color(.systemGray6))
            configuration
                .padding()
        }
    }
}
