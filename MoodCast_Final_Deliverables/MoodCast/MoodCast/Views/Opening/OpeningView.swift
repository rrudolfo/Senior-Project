//
//  OpeningView.swift
//  MoodCast
//
//  Created by Jacob Lucas on 4/1/25.
//

import SwiftUI

struct OpeningView: View {
    var body: some View {
        ZStack {
            VStack {
                header
                IntroCards()
                Spacer()
                footer
            }
        }
        .statusBarHidden()
        .padding()
        .navigationBarBackButtonHidden()
        .background {
            Color.accentColor.ignoresSafeArea()
        }
    }
}

extension OpeningView {
    private var header: some View {
        Text("**Mood**Cast")
            .font(.title)
            .foregroundStyle(.white)
            .padding(.bottom, 35)
    }
    
    private var footer: some View {
        VStack(spacing: 6) {
            Spacer()
            
            NavigationLink {
                CreateAccountView()
            } label: {
                Text("Create Account")
            }
            .buttonStyle(CapsuleButtonStyle(
                textColor: .accentColor,
                backgroundColor: .white
            ))
            
            NavigationLink {
                SignInView()
            } label: {
                Text("Sign In")
            }
            .buttonStyle(CapsuleButtonStyle(
                textColor: .white,
                backgroundColor: .clear
            ))
        }
    }
}

#Preview {
    OpeningView()
}
