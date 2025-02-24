//
//  DefaultTextFieldStyle.swift
//  CSCD-488-Project
//
//  Created by Jacob Lucas on 2/24/25.
//

import SwiftUI

struct PlainTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .frame(height: 45)
                .foregroundColor(Color(.systemGray6))
            RoundedRectangle(cornerRadius: 24)
                .stroke(lineWidth: 2 / UIScreen.main.scale)
                .frame(height: 45)
                .foregroundColor(Color(.systemGray4))
            configuration
                .padding()
        }
    }
}
