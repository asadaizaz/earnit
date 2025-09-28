//
//  ScreenTimeManager.swift
//  earnit
//
//  Created by Asad Aizaz on 2025-07-25.
//

import Foundation
import SwiftUI
import FamilyControls
import ManagedSettings
import DeviceActivity

// MARK: - ScreenTime Manager
class ScreenTimeManager: ObservableObject {
    @Published var isBlockingActive = false
    @Published var isAuthorized = false
    @Published var authorizationError: String?
    
    private let appState: AppStateManager
    private let store = ManagedSettingsStore()
    private let center = DeviceActivityCenter()
    
    // App Group UserDefaults for sharing with extensions
    private let sharedDefaults = UserDefaults(suiteName: "group.com.earnit.app") ?? UserDefaults.standard
    
    init(appState: AppStateManager) {
        self.appState = appState
        setupBlockingObserver()
        checkAuthorizationStatus()
    }
    
    // MARK: - Device Activity Constants
    private static let activityName = DeviceActivityName("earnit.monitoring")
    private static let eventName = DeviceActivityEvent.Name("earnit.app.access")
    
    // MARK: - Device Activity Helper Methods
    private func createSchedule() -> DeviceActivitySchedule {
        return DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )
    }
    
    private func createEvent(for selection: FamilyActivitySelection) -> DeviceActivityEvent {
        return DeviceActivityEvent(
            applications: selection.applicationTokens,
            categories: selection.categoryTokens,
            webDomains: selection.webDomainTokens,
            threshold: DateComponents(second: 0) // Trigger immediately on access
        )
    }
    
    private func setupBlockingObserver() {
        // Monitor app state changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        
        // Monitor habit completion
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(habitCompleted),
            name: .habitCompleted,
            object: nil
        )
    }
    
    @objc private func habitCompleted() {
        updateAppBlocking()
    }
    
    // MARK: - Family Controls Authorization
    
    private func checkAuthorizationStatus() {
        isAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
    }
    
    @MainActor
    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            isAuthorized = true
            authorizationError = nil
        } catch {
            isAuthorized = false
            authorizationError = error.localizedDescription
            print("Failed to get Family Controls authorization: \(error)")
        }
    }
    
    // MARK: - App Selection and Management
    
    func saveSelectedApps(_ selection: FamilyActivitySelection) {
        // Save the selection to shared UserDefaults for extension access
        if let data = try? JSONEncoder().encode(selection) {
            sharedDefaults.set(data, forKey: "SelectedApps")
        }
        
        // Start device activity monitoring
        startMonitoring(for: selection)
        
        // Apply blocking if habits are not completed
        updateAppBlocking()
    }
    
    private func loadSelectedApps() -> FamilyActivitySelection? {
        guard let data = sharedDefaults.data(forKey: "SelectedApps"),
              let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) else {
            return nil
        }
        return selection
    }
    
    func updateAppBlocking() {
        guard isAuthorized else { return }
        
        let allHabitsCompleted = appState.habits.allSatisfy { $0.isCompletedToday }
        isBlockingActive = !allHabitsCompleted && !appState.habits.isEmpty
        
        if let selection = loadSelectedApps() {
            if isBlockingActive {
                // Block the selected apps
                store.shield.applications = selection.applicationTokens
                
                // Block categories if any are selected
                if !selection.categoryTokens.isEmpty {
                    store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(selection.categoryTokens)
                }
                
                // Block web domains if any are selected
                if !selection.webDomainTokens.isEmpty {
                    store.shield.webDomains = selection.webDomainTokens
                }
            } else {
                // Unblock all apps
                store.clearAllSettings()
            }
        }
        
        // Update shared defaults for extensions
        sharedDefaults.set(isBlockingActive, forKey: "IsBlocking")
        sharedDefaults.set(allHabitsCompleted, forKey: "AllHabitsCompleted")
    }
    
    // MARK: - Device Activity Monitoring
    
    private func startMonitoring(for selection: FamilyActivitySelection) {
        guard isAuthorized else {
            print("Cannot start monitoring: not authorized")
            return
        }
        
        do {
            let schedule = createSchedule()
            let event = createEvent(for: selection)
            
            try center.startMonitoring(
                Self.activityName,
                during: schedule,
                events: [Self.eventName: event]
            )
            
            print("Started device activity monitoring")
        } catch {
            print("Failed to start monitoring: \(error)")
        }
    }
    
    func stopMonitoring() {
        center.stopMonitoring()
        print("Stopped device activity monitoring")
    }
    
    func restartMonitoring() {
        guard let selection = loadSelectedApps() else { return }
        stopMonitoring()
        startMonitoring(for: selection)
    }
    
    @objc private func appWillEnterForeground() {
        checkBlockingStatus()
    }
    
    private func checkBlockingStatus() {
        checkAuthorizationStatus()
        updateAppBlocking()
        
        // Update guarded apps blocking status for UI (legacy support)
        updateGuardedAppsStatus(shouldBlock: isBlockingActive)
    }
    
    private func updateGuardedAppsStatus(shouldBlock: Bool) {
        for index in appState.guardedApps.indices {
            appState.guardedApps[index].isBlocked = shouldBlock
        }
    }
    
    // MARK: - MVP Simulation Methods
    
    /// Simulates checking if a specific app should be blocked
    func shouldBlockApp(bundleIdentifier: String) -> Bool {
        // For MVP, we'll just return the general blocking status
        guard let guardedApp = appState.guardedApps.first(where: { $0.bundleIdentifier == bundleIdentifier }) else {
            return false
        }
        
        return guardedApp.isBlocked && isBlockingActive
    }
    
    /// Shows a blocking overlay when user tries to access a blocked app
    func showBlockingMessage(for appName: String) -> String {
        let incompleteHabits = appState.habits.filter { !$0.isCompletedToday }
        let habitNames = incompleteHabits.map { $0.title }.joined(separator: ", ")
        
        return "Complete your daily habits to unlock \(appName).\n\nRemaining: \(habitNames)"
    }
    
    /// For MVP: Opens Earn It app when user tries to access blocked app
    func redirectToEarnIt() {
        // In a real implementation, this would be triggered by the ScreenTime API
        // For MVP, this is just a placeholder for the concept
        print("Redirecting to Earn It app...")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Blocking Overlay View (for demonstration)
struct BlockingOverlayView: View {
    let appName: String
    let message: String
    let onOpenEarnIt: () -> Void
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: "lock.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.red)
                
                Text("\(appName) is Blocked")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(message)
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(spacing: 12) {
                    Button("Complete Habits") {
                        onOpenEarnIt()
                        isPresented = false
                    }
                    .buttonStyle(.borderedProminent)
                    .font(.headline)
                    
                    Button("Close") {
                        isPresented = false
                    }
                    .foregroundColor(.white)
                }
            }
            .padding()
        }
    }
}

#Preview {
    @State var isPresented = true
    
    return BlockingOverlayView(
        appName: "Instagram",
        message: "Complete your daily habits to unlock Instagram.\n\nRemaining: Morning Walk, Read 10 Pages",
        onOpenEarnIt: { print("Opening Earn It") },
        isPresented: $isPresented
    )
} 