//
//  DynamicSheet.swift
//  MoodCast
//
//  Created by Jacob Lucas on 5/6/25.
//

import SwiftUI

struct DynamicSheet<Content: View>: View {
    @State private var sheetContentHeight: CGFloat = 0
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .fixedSize(
                horizontal: false,
                vertical: true
            )
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .task {
                            sheetContentHeight = proxy.size.height
                        }
                }
            }
            .cornerRadius(30)
            .interactiveDismissDisabled(true)
            .presentationDetents([.height(sheetContentHeight)])
            .presentationCornerRadius(30)
    }
}
