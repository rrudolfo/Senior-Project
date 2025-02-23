//
//  OpeningView.swift
//  CSCD-488-Project
//
//  Created by Jacob Lucas on 2/21/25.
//

import SwiftUI
import BezelKit

struct OpeningView: View {
    
    let currentBezel = CGFloat.deviceBezel
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.accentColor
            
            VStack(spacing: 16) {
                HStack {
                    Text("Create Account")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(.label))
                        .padding(14)
                    Spacer()
                }
                
                TextField("name", text: .constant(""))
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 18)
                            .foregroundStyle(Color(.systemGray6))
                    }
                    .padding(.horizontal, 14)
                
                TextField("email", text: .constant(""))
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 18)
                            .foregroundStyle(Color(.systemGray6))
                    }
                    .padding(.horizontal, 14)
                
                TextField("password", text: .constant(""))
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 18)
                            .foregroundStyle(Color(.systemGray6))
                    }
                    .padding(.horizontal, 14)
                
                Button {
                    
                } label: {
                    HStack {
                        Spacer()
                        Text("Create Account")
                            .font(.title3)
                            .fontWeight(.medium)
                        Spacer()
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 18)
                            .foregroundStyle(Color(.label))
                    }
                    .padding(14)
                }
                
                Text("Already have an account? **Login**")
                    .foregroundStyle(Color(.label))
                    .padding(14)
            }
            .padding()
            .foregroundStyle(.white)
            .background {
                RoundedRectangle(cornerRadius: currentBezel - 10)
                    .foregroundStyle(.white)
            }
            .padding(10)
        }
        .ignoresSafeArea()
        .persistentSystemOverlays(.hidden)
    }
}

extension OpeningView {
    var stackBackground: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: currentBezel - 13)
                .frame(height: UIScreen.main.bounds.height / 1.6)
                .padding(42)
                .offset(y: -4)
                .opacity(0.1)
            RoundedRectangle(cornerRadius: currentBezel - 13)
                .frame(height: UIScreen.main.bounds.height / 1.6)
                .padding(26)
                .offset(y: -4)
                .opacity(0.5)
            RoundedRectangle(cornerRadius: currentBezel - 13)
                .frame(height: UIScreen.main.bounds.height / 1.6)
                .padding(13)
        }
        .foregroundStyle(.white)
    }
}

#Preview {
    OpeningView()
}
