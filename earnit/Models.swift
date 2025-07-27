//
//  Models.swift
//  earnit
//
//  Created by Asad Aizaz on 2025-07-25.
//

import Foundation
import SwiftUI
import FamilyControls

extension Notification.Name {
    static let habitCompleted = Notification.Name("habitCompleted")
}

// MARK: - Habit Model
struct Habit: Identifiable, Codable {
    let id = UUID()
    var title: String
    var description: String
    var isCompletedToday: Bool = false
    var proofPhotoData: Data?
    var completedAt: Date?
    
    mutating func markCompleted(with photoData: Data) {
        self.isCompletedToday = true
        self.proofPhotoData = photoData
        self.completedAt = Date()
    }
    
    mutating func resetForNewDay() {
        self.isCompletedToday = false
        self.proofPhotoData = nil
        self.completedAt = nil
    }
}

// MARK: - Guarded App Model
struct GuardedApp: Identifiable, Codable {
    let id = UUID()
    var name: String
    var bundleIdentifier: String
    var iconName: String
    var isBlocked: Bool = true
    
    // Common social media apps for easy selection
    static let defaultApps: [GuardedApp] = [
        GuardedApp(name: "Instagram", bundleIdentifier: "com.burbn.instagram", iconName: "camera.fill"),
        GuardedApp(name: "TikTok", bundleIdentifier: "com.zhiliaoapp.musically", iconName: "music.note"),
        GuardedApp(name: "Twitter", bundleIdentifier: "com.atebits.Tweetie2", iconName: "at"),
        GuardedApp(name: "Facebook", bundleIdentifier: "com.facebook.Facebook", iconName: "person.2.fill"),
        GuardedApp(name: "YouTube", bundleIdentifier: "com.google.ios.youtube", iconName: "play.rectangle.fill"),
        GuardedApp(name: "Snapchat", bundleIdentifier: "com.toyopagroup.picaboo", iconName: "camera.circle.fill")
    ]
}

// MARK: - App State Manager
class AppStateManager: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var guardedApps: [GuardedApp] = []
    @Published var isOnboardingComplete: Bool = false
    @Published var lastResetDate: Date = Date()
    @Published var shouldNavigateToProof: Bool = false
    @Published var selectedAppsConfiguration: FamilyActivitySelection = FamilyActivitySelection()
    
    init() {
        loadData()
        checkForNewDay()
    }
    
    // Check if it's a new day and reset habits
    func checkForNewDay() {
        let calendar = Calendar.current
        if !calendar.isDate(lastResetDate, inSameDayAs: Date()) {
            resetHabitsForNewDay()
            lastResetDate = Date()
            saveData()
        }
    }
    
    private func resetHabitsForNewDay() {
        for index in habits.indices {
            habits[index].resetForNewDay()
        }
        
        // Re-block all apps for new day
        for index in guardedApps.indices {
            guardedApps[index].isBlocked = true
        }
    }
    
    func completeHabit(habitId: UUID, with photoData: Data) {
        if let index = habits.firstIndex(where: { $0.id == habitId }) {
            habits[index].markCompleted(with: photoData)
            checkIfAllHabitsCompleted()
            saveData()
            
            // Post notification to update screen time blocking
            NotificationCenter.default.post(name: .habitCompleted, object: nil)
        }
    }
    
    private func checkIfAllHabitsCompleted() {
        let allCompleted = habits.allSatisfy { $0.isCompletedToday }
        if allCompleted {
            // Unblock all apps
            for index in guardedApps.indices {
                guardedApps[index].isBlocked = false
            }
        }
    }
    
    func addHabit(_ habit: Habit) {
        habits.append(habit)
        saveData()
    }
    
    func addGuardedApp(_ app: GuardedApp) {
        guardedApps.append(app)
        saveData()
    }
    
    func completeOnboarding() {
        isOnboardingComplete = true
        saveData()
    }
    
    // MARK: - Persistence
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(encoded, forKey: "SavedHabits")
        }
        if let encoded = try? JSONEncoder().encode(guardedApps) {
            UserDefaults.standard.set(encoded, forKey: "SavedGuardedApps")
        }
        UserDefaults.standard.set(isOnboardingComplete, forKey: "OnboardingComplete")
        UserDefaults.standard.set(lastResetDate, forKey: "LastResetDate")
    }
    
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: "SavedHabits"),
           let decodedHabits = try? JSONDecoder().decode([Habit].self, from: data) {
            habits = decodedHabits
        }
        
        if let data = UserDefaults.standard.data(forKey: "SavedGuardedApps"),
           let decodedApps = try? JSONDecoder().decode([GuardedApp].self, from: data) {
            guardedApps = decodedApps
        }
        
        isOnboardingComplete = UserDefaults.standard.bool(forKey: "OnboardingComplete")
        
        if let savedDate = UserDefaults.standard.object(forKey: "LastResetDate") as? Date {
            lastResetDate = savedDate
        }
    }
} 