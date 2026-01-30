//
//  CreateAccountViewModel.swift
//  MoodCast
//
//  Created by Jacob Lucas on 4/1/25.
//

import Foundation

class CreateAccountViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    
    @Published var isLoading: Bool = false
    
    func createAccount() {
        if name.isEmpty || email.isEmpty || password.isEmpty {
            print("TextFields cannot be empty.")
            return
        }
        
        toggleLoading()
        
        Task {
            do {
                let authService = AuthService.shared
                try await authService.createAccount(name: name, email: email, password: password)
                toggleLoading()
            } catch(let error) {
                print("Error creating account: ", error)
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
