//
//  ShieldConfigurationExtension.swift
//  ShieldConfiguration
//
//  Created by Asad Aizaz on 2025-09-28.
//

import ManagedSettings
import ManagedSettingsUI
import UIKit

// Override the functions below to customize the shields used in various situations.
// The system provides a default appearance for any methods that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        // Customize the shield as needed for applications.
        return ShieldConfiguration(
            backgroundBlurStyle: .systemMaterial,
            backgroundColor: UIColor.systemPurple,
            icon: UIImage(systemName: "lock.fill"),
            title: ShieldConfiguration.Label(
                text: "Complete Your Habits",
                color: .white
            ),
            subtitle: ShieldConfiguration.Label(
                text: "Finish your daily habits to unlock this app",
                color: .white
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Open Earn It",
                color: .white
            ),
            primaryButtonBackgroundColor: UIColor.systemBlue
        )
    }
    
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        // Customize the shield as needed for applications shielded because of their category.
        return ShieldConfiguration(
            backgroundBlurStyle: .systemMaterial,
            backgroundColor: UIColor.systemPurple,
            icon: UIImage(systemName: "lock.fill"),
            title: ShieldConfiguration.Label(
                text: "Complete Your Habits",
                color: .white
            ),
            subtitle: ShieldConfiguration.Label(
                text: "Finish your daily habits to unlock this app",
                color: .white
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Open Earn It",
                color: .white
            ),
            primaryButtonBackgroundColor: UIColor.systemBlue
        )
    }
    
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        // Customize the shield as needed for web domains.
        return ShieldConfiguration(
            backgroundBlurStyle: .systemMaterial,
            backgroundColor: UIColor.systemPurple,
            icon: UIImage(systemName: "lock.fill"),
            title: ShieldConfiguration.Label(
                text: "Complete Your Habits",
                color: .white
            ),
            subtitle: ShieldConfiguration.Label(
                text: "Finish your daily habits to unlock this app",
                color: .white
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Open Earn It",
                color: .white
            ),
            primaryButtonBackgroundColor: UIColor.systemBlue
        )
    }
    
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        // Customize the shield as needed for web domains shielded because of their category.
        return ShieldConfiguration(
            backgroundBlurStyle: .systemMaterial,
            backgroundColor: UIColor.systemPurple,
            icon: UIImage(systemName: "lock.fill"),
            title: ShieldConfiguration.Label(
                text: "Complete Your Habits",
                color: .white
            ),
            subtitle: ShieldConfiguration.Label(
                text: "Finish your daily habits to unlock this app",
                color: .white
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Open Earn It",
                color: .white
            ),
            primaryButtonBackgroundColor: UIColor.systemBlue
        )
    }
}
