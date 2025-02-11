//
//  ContentView.swift
//  CSCD-488-Project
//
//  Created by Jacob Lucas on 2/6/25.
//
//View is a protocol

import SwiftUI

struct ContentView: View {
    let auth = AuthService.shared
    var body: some View {
        Button("TEST SERVER CONNECTION") {
            auth.testServerConnection()
        }
    }
}

#Preview {
    ContentView()
}
