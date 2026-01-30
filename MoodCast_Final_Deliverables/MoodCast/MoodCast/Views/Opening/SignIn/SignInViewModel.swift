//
//  SignInViewModel.swift
//  MoodCast
//
//  Created by Jacob Lucas on 4/1/25.
//

import Foundation

class SignInViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    
    @Published var isLoading: Bool = false
    
    func signIn() {
        if email.isEmpty || password.isEmpty {
            print("TextFields cannot be empty.")
            return
        }
        
        toggleLoading()
        
        Task {
            do {
                let authService = AuthService.shared
                try await authService.signIn(email: email, password: password)
                toggleLoading()
            } catch(let error) {
                print("Error signing in to your account: ", error)
                toggleLoading()
            }
        }
    }
    
    private func toggleLoading() {
        DispatchQueue.main.async {
            self.isLoading.toggle()
        }
    }
}
