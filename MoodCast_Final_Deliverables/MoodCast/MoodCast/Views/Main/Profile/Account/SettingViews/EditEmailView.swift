//
//  EditEmailView.swift
//  MoodCast
//
//  Created by Jacob Lucas on 4/5/25.
//

import SwiftUI

struct EditEmailView: View {
    
    @State var text: String = ""
    @State var isLoading: Bool = false
    
    @AppStorage("user_id") var currentUserId: String?
    @AppStorage("email") var currentUserEmail: String?
    @AppStorage("name") var currentUserName: String?
    
    @FocusState var focusState: Bool
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        content
    }
}

extension EditEmailView {
    private var content: some View {
        VStack {
            heading
            Spacer(minLength: 0)
            textField
            Spacer(minLength: 0)
            button
        }
        .padding()
        .navigationBarBackButtonHidden()
    }
    
    private var heading: some View {
        ZStack {
            Text("Edit Email")
                .font(.title2)
                .fontWeight(.bold)
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                .buttonStyle(ButtonScaleStyle())
                Spacer()
            }
        }
        .font(.headline)
    }
    
    private var textField: some View {
        TextField("Email", text: $text)
            .textFieldStyle(CapsuleTextFieldStyle())
            .focused($focusState)
            .onAppear { focusState.toggle() }
    }
    
    private var button: some View {
        Button {
            saveDetails()
        } label: {
            Text("Save")
        }
        .buttonStyle(CapsuleButtonStyle(
            textColor: .white,
            backgroundColor: .accentColor)
        )
    }
    
    private func saveDetails() {
        guard let userId = currentUserId, let name = currentUserName else {
            print("Unable to unwrap user id in Edit Name View.")
            return
        }
        if (!text.isEmpty) {
            print("Text field cannot be empty.")
            return
        }
        
        isLoading.toggle()
        
        let userModel = UserModel(
            userId: userId,
            name: name,
            email: text,
            spotifyLinked: true
        )
        
        Task {
            do {
                let dataService = DataService.shared
                try await dataService.saveUserModelToFirestore(userModel: userModel)
                
                toggleFields()
                self.currentUserEmail = text
                print("Success saving name.")
            } catch(let error) {
                toggleFields()
                print("Error saving name: ", error)
            }
        }
    }
    
    private func toggleFields() {
        DispatchQueue.main.async {
            isLoading.toggle()
            focusState.toggle()
        }
    }
}


#Preview {
    EditEmailView()
}
