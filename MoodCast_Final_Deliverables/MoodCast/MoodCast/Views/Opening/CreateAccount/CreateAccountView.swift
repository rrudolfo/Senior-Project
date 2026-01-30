//
//  CreateAccountView.swift
//  MoodCast
//
//  Created by Jacob Lucas on 4/1/25.
//

import SwiftUI

struct CreateAccountView: View {
    @StateObject var viewModel = CreateAccountViewModel()
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

extension CreateAccountView {
    private var header: some View {
        ZStack {
            HStack {
                ButtonTypes.leftArrow.view
                Spacer()
            }
            Text("Create Account")
                .font(.title3)
                .fontWeight(.medium)
        }
    }
    
    private var content: some View {
        VStack(spacing: 6) {
            TextField("name", text: $viewModel.name)
            TextField("email", text: $viewModel.email)
            SecureField("password", text: $viewModel.password)
        }
        .textFieldStyle(CapsuleTextFieldStyle())
    }
    
    private var footer: some View {
        VStack(spacing: 12) {
            Button {
                viewModel.createAccount()
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Create Account")
                }
            }
            .buttonStyle(CapsuleButtonStyle(
                textColor: .white,
                backgroundColor: .accentColor
            ))
            
            Text("By creating an account, you are agreeing to our **Terms & Conditions** and Privacy **Policy**.")
                .multilineTextAlignment(.center)
                .foregroundStyle(Color(.systemGray))
                .font(.footnote)
        }
    }
}

#Preview {
    CreateAccountView()
}
