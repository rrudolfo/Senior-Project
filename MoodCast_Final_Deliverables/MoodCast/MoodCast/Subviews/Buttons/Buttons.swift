//
//  Buttons.swift
//  MoodCast
//
//  Created by Jacob Lucas on 4/1/25.
//

import SwiftUI

enum ButtonTypes {
    case leftArrow

    var view: some View {
        switch self {
        case .leftArrow:
            return LeftArrow()
        }
    }
}

struct LeftArrow: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "arrow.left")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(Color(.label))
                .padding(8)
                .background {
                    Circle()
                        .foregroundStyle(Color(.systemGray6))
                }
        }
    }
}

struct XMark: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(Color(.label))
                .padding(8)
                .background {
                    Circle()
                        .foregroundStyle(Color(.systemGray6))
                }
        }
    }
}


