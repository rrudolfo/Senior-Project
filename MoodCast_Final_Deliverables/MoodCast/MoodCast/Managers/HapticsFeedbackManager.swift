//
//  HapticsFeedbackManager.swift
//  MoodCast
//
//  Created by Jacob Lucas on 4/1/25.
//

import UIKit

class HapticsFeedbackManager {
    static let shared = HapticsFeedbackManager()
    
    private init() {}
    
    func triggerVibration() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    func triggerFailureHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}
