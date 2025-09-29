//
//  ShieldActionExtension.swift
//  earnit
//
//  Created by AI Assistant on 2025-07-25.
//

import ManagedSettings
import ManagedSettingsUI
import UIKit
import Foundation
import FamilyControls

// MARK: - Shield Action Delegate (modern Screen Time API)
// This class must be located in the Shield Action Extension target and declared as its principal class.

class EarnitShieldActionDelegate: ShieldActionDelegate {
    // Handle actions for individual apps
    func handle(_ action: ShieldAction, for application: Application, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        process(action, completionHandler: completionHandler)
    }

    // Handle actions for application categories
    func handle(_ action: ShieldAction, for applicationCategory: ActivityCategory, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        process(action, completionHandler: completionHandler)
    }

    // Handle actions for web domains
    func handle(_ action: ShieldAction, for webDomain: WebDomain, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        process(action, completionHandler: completionHandler)
    }

    // Shared processing logic
    private func process(_ action: ShieldAction, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        let defaults = UserDefaults(suiteName: "group.com.asad.earnit") ?? .standard
        let habitsCompleted = defaults.bool(forKey: "AllHabitsCompleted")

        switch action {
        case .primaryButtonPressed:
            if habitsCompleted {
                completionHandler(.close)
            } else {
                openEarnItApp()
                completionHandler(.defer)
            }
        case .secondaryButtonPressed:
            completionHandler(.close)
        @unknown default:
            completionHandler(.close)
        }
    }

    private func openEarnItApp() {
        guard let url = URL(string: "earnit://proof-submission"),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - Helper Extension
extension EarnitShieldActionDelegate {
    /// Check if habits are completed from shared storage
    func areHabitsCompleted() -> Bool {
        let sharedDefaults = UserDefaults(suiteName: "group.com.asad.earnit") ?? UserDefaults.standard
        return sharedDefaults.bool(forKey: "AllHabitsCompleted")
    }
}

