//
//  AccountView.swift
//  MoodCast
//
//  Created by Jacob Lucas on 4/5/25.
//

import SwiftUI

struct AccountView: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        content
    }
}

extension AccountView {
    private var content: some View {
        VStack {
            heading
            editItems
            Spacer(minLength: 0)
            deleteAccountButton
        }
        .navigationBarBackButtonHidden()
    }
    
    private var heading: some View {
        ZStack {
            Text("Settings")
                .font(.title2)
                .fontWeight(.bold)
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                .buttonStyle(ButtonScaleStyle())
                Spacer()
            }
        }
        .padding()
    }
    
    private var editItems: some View {
        VStack(spacing: 0) {
            NavigationLink {
                EditNameView()
            } label: {
                SettingCell(title: "Edit Name")
            }
            
            NavigationLink {
                EditEmailView()
            } label: {
                SettingCell(title: "Edit Email")
            }
            
            Button {
                signOut()
            } label: {
                SettingCell(
                    icon: "rectangle.portrait.and.arrow.right",
                    title: "Log Out",
                    isLink: true
                )
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func signOut() {
        let authService = AuthService.shared
        authService.signOut()
    }
    
    private var deleteAccountButton: some View {
        Button {
            
        } label: {
            Text("Delete Account")
        }
        .buttonStyle(CapsuleButtonStyle(
            textColor: colorScheme == .light ? .white : .black,
            backgroundColor: Color(.label))
        )
        .padding()
    }
}

#Preview {
    AccountView()
}
