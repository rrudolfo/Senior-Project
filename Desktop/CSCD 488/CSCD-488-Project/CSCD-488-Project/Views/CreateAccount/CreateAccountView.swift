//
//  CreateAccountView.swift
//  CSCD-488-Project
//
//  Created by Jacob Lucas on 2/22/25.
//

import SwiftUI

struct CreateAccountView: View {
    @State var name: String = ""
    @State var email: String = ""
    @State var password: String = ""
    var body: some View {
        VStack {
            TextField("name", text: $name)
            TextField("email", text: $email)
            TextField("password", text: $password)
        }
    }
}

#Preview {
    CreateAccountView()
}
