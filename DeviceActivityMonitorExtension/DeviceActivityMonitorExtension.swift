//
//  DeviceActivityMonitorExtension.swift
//  DeviceActivityMonitorExtension
//
//  Created by Kiro on 2025-09-28.
//

import DeviceActivity
import Foundation
import FamilyControls

// MARK: - Device Activity Monitor Extension
class EarnitDeviceActivityMonitor: DeviceActivityMonitor {
    
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        
        // Called when monitoring begins
        print("Device activity monitoring started for: \(activity)")
        updateSharedState()
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        
        // Called when monitoring ends (usually at end of day)
        print("Device activity monitoring ended for: \(activity)")
    }
    
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        
        // Called when user tries to access a blocked app
        print("Event reached threshold: \(event) for activity: \(activity)")
        
        // Check if habits are completed
        let sharedDefaults = UserDefaults(suiteName: "group.com.earnit.app") ?? UserDefaults.standard
        let allHabitsCompleted = sharedDefaults.bool(forKey: "AllHabitsCompleted")
            
        if !allHabitsCompleted {
            // User tried to access blocked app but hasn't completed habits
            // The shield will be shown automatically by the system
            print("Blocking app access - habits not completed")
        } else {
            // All habits completed, allow access
            print("Allowing app access - all habits completed")
        }
    }
    
    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
        
        // Called before monitoring starts (optional)
        print("Device activity monitoring will start warning for: \(activity)")
    }
    
    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
        
        // Called before monitoring ends (optional)
        print("Device activity monitoring will end warning for: \(activity)")
    }
    
    private func updateSharedState() {
        // Update shared preferences for shield extensions
        let sharedDefaults = UserDefaults(suiteName: "group.com.earnit.app") ?? UserDefaults.standard
        sharedDefaults.set(Date(), forKey: "LastMonitoringUpdate")
    }
}

// MARK: - Monitoring Configuration
extension EarnitDeviceActivityMonitor {
    
    static let activityName = DeviceActivityName("earnit.monitoring")
    static let eventName = DeviceActivityEvent.Name("earnit.app.access")
    
    static func createSchedule() -> DeviceActivitySchedule {
        let calendar = Calendar.current
        let startTime = calendar.startOfDay(for: Date())
        let endTime = calendar.date(byAdding: .day, value: 1, to: startTime)!
        
        return DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )
    }
    
    static func createEvent(for selection: FamilyActivitySelection) -> DeviceActivityEvent {
        return DeviceActivityEvent(
            applications: selection.applicationTokens,
            categories: selection.categoryTokens,
            webDomains: selection.webDomainTokens,
            threshold: DateComponents(second: 0) // Trigger immediately on access
        )
    }
}