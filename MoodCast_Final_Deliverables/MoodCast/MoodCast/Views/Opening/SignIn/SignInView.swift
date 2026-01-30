//
//  SignInView.swift
//  MoodCast
//
//  Created by Jacob Lucas on 4/1/25.
//

import SwiftUI

struct SignInView: View {
    @StateObject var viewModel = SignInViewModel()
    var body: some View {
        VStack {
            header
            Spacer()
            content
            Spacer()
            footer
        }
        .padding()
        .navigationBarBackButtonHidden()
    }
}

extension SignInView {
    private var header: some View {
        ZStack {
            HStack {
                ButtonTypes.leftArrow.view
                Spacer()
            }
            Text("Sign In")
                .font(.title3)
                .fontWeight(.medium)
        }
    }
    
    private var content: some View {
        VStack(spacing: 6) {
            TextField("email", text: $viewModel.email)
            SecureField("password", text: $viewModel.password)
        }
        .textFieldStyle(CapsuleTextFieldStyle())
    }
    
    private var footer: some View {
            Button {
                viewModel.signIn()
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Sign In")
                }
            }
            .buttonStyle(CapsuleButtonStyle(
                textColor: .white,
                backgroundColor: .accentColor
            ))
    }
}

#Preview {
    SignInView()
}
