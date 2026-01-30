//
//  MoodCastApp.swift
//  MoodCast
//
//  Created by Jacob Lucas on 4/1/25.
//

import SwiftUI

@main
struct MoodCastApp: App {
    @AppStorage("user_id") var currentUserId: String?
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            if currentUserId != nil {
                NavigationView {
                     MainView()
                }
            } else {
                NavigationView {
                    OpeningView()
                }
            }
        }
    }
}
