//
//  ShieldConfigurationExtension.swift
//  ShieldConfigurationExtension
//
//  Created by Kiro on 2025-09-28.
//

import ManagedSettings
import ManagedSettingsUI
import UIKit
import os

// MARK: - Shield Configuration Extension
@objc(EarnitShieldConfigurationDataSource)
class EarnitShieldConfigurationDataSource: ShieldConfigurationDataSource {
    let shieldLog  = Logger(subsystem: "com.asad.earnit", category: "Shield")

    override init() {
        super.init()
        
        shieldLog.info("🛡️ ShieldConfigurationExtension INITIALIZED!")
        NSLog("🛡️ ShieldConfigurationExtension INITIALIZED!")
    }
    
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        return createShieldConfiguration()
    }
    
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        return createShieldConfiguration()
    }
    
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        return createShieldConfiguration()
    }
    
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        return createShieldConfiguration()
    }
    
    // MARK: - Private Methods
    
    private func createShieldConfiguration() -> ShieldConfiguration {
        // Debug logging - this should appear in console if extension is called
        shieldLog.info("🛡️ Shield Configuration Extension Called!")
        NSLog("🛡️ Shield Configuration Extension Called!")
        
        // Custom shield configuration
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
