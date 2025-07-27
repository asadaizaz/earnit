//
//  ShieldConfigurationExtension.swift
//  earnit
//
//  Created by AI Assistant on 2025-07-25.
//

import ManagedSettings
import ManagedSettingsUI
import UIKit
import FamilyControls

// MARK: - Shield Configuration Data Source (Modern API)
// Move this to a Shield Configuration Extension target.

class EarnitShieldConfigurationDataSource: ShieldConfigurationDataSource {
    // Configuration for individual apps
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        buildConfiguration(isLocked: !areHabitsCompleted())
    }
    // Configuration for applications in categories
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        buildConfiguration(isLocked: !areHabitsCompleted())
    }
    
    // Configuration for web domains
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        buildConfiguration(isLocked: !areHabitsCompleted())
    }
    
    // Configuration for web domains in categories
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        buildConfiguration(isLocked: !areHabitsCompleted())
    }
    // Shared builder
    private func buildConfiguration(isLocked: Bool) -> ShieldConfiguration {
        if isLocked {
            return ShieldConfiguration(
                backgroundBlurStyle: .systemMaterial,
                backgroundColor: UIColor.systemRed.withAlphaComponent(0.8),
                icon: UIImage(systemName: "lock.shield.fill"),
                title: .init(text: "Time to Earn It!", color: .white),
                subtitle: .init(text: "Complete your daily habits to unlock", color: .white),
                primaryButtonLabel: .init(text: "Complete Habits", color: .white),
                primaryButtonBackgroundColor: .systemBlue,
                secondaryButtonLabel: .init(text: "Close", color: .white)
            )
        } else {
            return ShieldConfiguration(
                backgroundBlurStyle: .systemMaterial,
                backgroundColor: UIColor.systemGreen.withAlphaComponent(0.8),
                icon: UIImage(systemName: "checkmark.circle.fill"),
                title: .init(text: "Unlocked!", color: .white),
                subtitle: .init(text: "Great job completing your habits", color: .white),
                primaryButtonLabel: .init(text: "Open App", color: .white),
                primaryButtonBackgroundColor: .systemBlue
            )
        }
    }
    // Helper
    private func areHabitsCompleted() -> Bool {
        let sharedDefaults = UserDefaults(suiteName: "group.com.earnit.app") ?? UserDefaults.standard
        return sharedDefaults.bool(forKey: "AllHabitsCompleted")
    }
} 
