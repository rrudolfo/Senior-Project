//
//  Menu.swift
//  MoodCast
//
//  Created by Jacob Lucas on 4/1/25.
//

import SwiftUI

struct Menu: View {
    
    @Binding var index: Int
    
    let hapticsManager = HapticsFeedbackManager.shared
    
    @Environment(\.colorScheme) var colorScheme
    
    var icons: [String] = [
        "house.fill",
        "magnifyingglass",
        "person.crop.circle.fill"
    ]
    
    var titles: [String] = [
        "Home",
        "Search",
        "Profile"
    ]
    
    var body: some View {
        HStack {
            ForEach(icons.indices, id: \.self) { icon in
                createIcon(icon)
            }
        }
        .padding(.top)
        .padding(.vertical, 6)
        .background {
            Color(.systemGray6)
                .edgesIgnoringSafeArea(.bottom)
        }
    }
}

struct Menu_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            Menu(index: .constant(0))
        }
    }
}

extension Menu {
    func createIcon(_ icon: Int) -> some View {
        Button {
            index = icon
            hapticsManager.triggerVibration()
        } label: {
            Image(systemName: icons[icon])
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(height: 20)
                .frame(maxWidth: .infinity)
                .fontWeight(.medium)
                .foregroundColor(icons[icon] == icons[index] ? Color(.label) : Color(.systemGray4))
        }
    }
}
