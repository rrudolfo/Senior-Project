//
//  ProfileView.swift
//  MoodCast
//
//  Created by Jacob Lucas on 4/5/25.
//

import SwiftUI

struct ProfileView: View {
    @State var showAccountView: Bool = false
    @State var showSettingsView: Bool = false
    
    @State var profileDetails: SpotifyProfileModel? = nil
    @State var image: UIImage? = nil
    
    @AppStorage("user_followers") var currentUserFollowers: Int?
    @AppStorage("user_country") var currentUserCountry: String?
    @AppStorage("image_url") var imageUrl: String?
    @AppStorage("user_name") var currentUserName: String?
    @AppStorage("user_email") var currentUserEmail: String?
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            content
        }
        .onAppear {
            Task {
                if let url = imageUrl {
                    self.image = try await DataService.shared.retrieveImageFromUrl(imageUrl: url)
                }
            }
        }
    }
}

extension ProfileView {
    private var profileWidget: some View {
        VStack(spacing: 16) {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 95, height: 95)
                    .clipShape(Circle())
                    .overlay {
                        Circle()
                            .stroke(lineWidth: 2)
                            .foregroundStyle(Color(.systemGray5))
                    }
            } else {
                Image("profile_image")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 95, height: 95)
                    .clipShape(Circle())
                    .overlay {
                        Circle()
                            .stroke(lineWidth: 2)
                            .foregroundStyle(Color(.systemGray5))
                    }
            }
            
            VStack(spacing: 6) {
                Text(currentUserName ?? "no name")
                    .font(.title3)
                    .fontWeight(.semibold)
                Text(verbatim: currentUserEmail ?? "no email")
                    .font(.headline)
                    .fontWeight(.regular)
                    .foregroundStyle(Color(.systemGray))
                
            }
            .padding(.vertical, 3)
            
            HStack {
                Spacer()
                VStack(spacing: 4) {
                    Text(String(currentUserFollowers ?? 0))
                        .font(.subheadline)
                        .fontWeight(.bold)
                    Text("Followers")
                        .font(.caption)
                        .fontWeight(.regular)
                }
                Spacer()
                VStack(spacing: 4) {
                    if let country = currentUserCountry, !country.isEmpty {
                        Text(country)
                            .font(.subheadline)
                            .fontWeight(.bold)
                    } else {
                        Text("USA")
                            .font(.subheadline)
                            .fontWeight(.bold)
                    }
                    Text("Country")
                        .font(.caption)
                        .fontWeight(.regular)
                }
                Spacer()
            }
        }
        .padding()
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            heading
            
            Button {
                showAccountView.toggle()
            } label: {
                profileWidget
            }
            .buttonStyle(ButtonScaleStyle())
            
            NavigationLink {
                AppearanceView()
            } label: {
                SettingCell(
                    icon: "sun.max.fill",
                    title: "Appearance"
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            NavigationLink {
                LinkedAccountsView()
            } label: {
                SettingCell(
                    icon: "building.columns.fill",
                    title: "Linked Accounts"
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            SettingCell(
                icon: "phone.fill",
                title: "Contact",
                isLink: true
            )
            .onTapGesture {
                if let url = URL(string: "https://example.com/contact") {
                    UIApplication.shared.open(url)
                }
            }
            
            SettingCell(
                icon: "lock.fill",
                title: "Privacy Policy",
                isLink: true
            )
            .onTapGesture {
                if let url = URL(string: "https://example.com/privacypolicy") {
                    UIApplication.shared.open(url)
                }
            }
            
            SettingCell(
                icon: "list.bullet.rectangle.portrait.fill",
                title: "Terms of Use",
                isLast: true,
                isLink: true
            )
            .onTapGesture {
                if let url = URL(string: "https://example.com/contact") {
                    UIApplication.shared.open(url)
                }
            }
            
            Spacer()
        }
    }
    
    private var heading: some View {
        HStack {
            Text("Profile")
                .font(.title2)
                .fontWeight(.bold)
            Spacer()
            Button {
                showSettingsView.toggle()
            } label: {
                Image(systemName: "gearshape")
                    .font(.title3)
                    .fontWeight(.medium)
            }
            .buttonStyle(ButtonScaleStyle())
            .fullScreenCover(isPresented: $showSettingsView) {
                NavigationView {
                    AccountView()
                }
            }
        }
        .padding([.top, .horizontal])
    }
}

struct SettingCell: View {
    let icon: String?
    let title: String
    let isLast: Bool
    let isLink: Bool
    
    init(icon: String? = nil, title: String, isLast: Bool = false, isLink: Bool = false) {
        self.icon = icon
        self.title = title
        self.isLast = isLast
        self.isLink = isLink
    }
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.subheadline)
            }
            Text(title)
                .font(.subheadline)
            Spacer()
            if !isLink {
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .fontWeight(.semibold)
            }
        }
        .fontWeight(.semibold)
        .padding()
        .padding(.vertical, 8)
        .background {
            RoundedRectangle(cornerRadius: 14)
                .foregroundStyle(Color(.systemGray6))
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationView {
        ProfileView()
    }
}

struct LinkedAccountsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("linked_spotify_id") var linkedSpotifyId: String?
    var body: some View {
        content
    }
}

extension LinkedAccountsView {
    private var content: some View {
        VStack {
            heading
            accountDetails
            Spacer()
        }
        .navigationBarBackButtonHidden()
    }
    
    private var heading: some View {
        ZStack {
            Text("Linked Account")
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
        .font(.title3)
        .fontWeight(.semibold)
        .padding()
    }
    
    private var accountDetails: some View {
        VStack {
            HStack {
                Text(linkedSpotifyId ?? "n/a")
                Spacer(minLength: 0)
            }
            .padding()
            Divider()
        }
        .padding(.leading)
    }
}

struct AppearanceView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        content
    }
}

extension AppearanceView {
    private var content: some View {
        VStack {
            heading
            appearanceSelection
            Spacer()
        }
        .navigationBarBackButtonHidden()
    }
    
    private var heading: some View {
        ZStack {
            Text("Appearance")
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
        .font(.title3)
        .fontWeight(.semibold)
        .padding()
    }
    
    private var appearanceSelection: some View {
        VStack {
            AppearanceItem(
                title: "Light",
                isSelected: true
            )
            
            AppearanceItem(
                title: "Dark",
                isSelected: false
            )
            
            AppearanceItem(
                title: "System",
                isSelected: false
            )
        }
    }
}

struct AppearanceItem: View {
    let title: String
    let isSelected: Bool
    var body: some View {
        VStack {
            HStack {
                Text("System")
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                }
            }
            .padding()
            Divider()
        }
        .padding(.leading)
    }
}
