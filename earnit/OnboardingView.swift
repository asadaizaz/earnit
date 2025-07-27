//
//  OnboardingView.swift
//  earnit
//
//  Created by Asad Aizaz on 2025-07-25.
//

import SwiftUI
import FamilyControls

struct OnboardingView: View {
    @ObservedObject var appState: AppStateManager
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @State private var currentStep = 0
    @State private var newHabitTitle = ""
    @State private var newHabitDescription = ""
    @State private var selectedApps: Set<UUID> = []
    @State private var showingFamilyActivityPicker = false
    
    var body: some View {
        TabView(selection: $currentStep) {
            // Welcome Screen
            WelcomeStepView()
                .tag(0)
            
            // Habit Selection
            HabitSelectionStepView(
                newHabitTitle: $newHabitTitle,
                newHabitDescription: $newHabitDescription,
                habits: appState.habits,
                onAddHabit: addHabit
            )
            .tag(1)
            
            // Authorization Step
            AuthorizationStepView(
                screenTimeManager: screenTimeManager,
                onContinue: { currentStep = 3 }
            )
            .tag(2)
            
            // App Selection
            AppSelectionStepView(
                selectedApps: $selectedApps,
                showingFamilyActivityPicker: $showingFamilyActivityPicker,
                onComplete: completeOnboarding
            )
            .tag(3)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .sheet(isPresented: $showingFamilyActivityPicker) {
            FamilyActivityPickerView(isPresented: $showingFamilyActivityPicker) { selection in
                appState.selectedAppsConfiguration = selection
                screenTimeManager.saveSelectedApps(selection)
            }
        }
    }
    
    private func addHabit() {
        guard !newHabitTitle.isEmpty else { return }
        
        let habit = Habit(
            title: newHabitTitle,
            description: newHabitDescription.isEmpty ? "Complete this habit daily" : newHabitDescription
        )
        
        appState.addHabit(habit)
        newHabitTitle = ""
        newHabitDescription = ""
    }
    
    private func completeOnboarding() {
        // Add selected apps to guarded apps (for backward compatibility with demo)
        let defaultApps = GuardedApp.defaultApps
        for appId in selectedApps {
            if let app = defaultApps.first(where: { $0.id == appId }) {
                appState.addGuardedApp(app)
            }
        }
        
        appState.completeOnboarding()
    }
}

// MARK: - Welcome Step
struct WelcomeStepView: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Welcome to Earn It")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Show a photo, earn phone time.")
                .font(.title2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Set daily habits")
                }
                
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Choose apps to guard")
                }
                
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Upload proof photos")
                }
                
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Unlock your apps")
                }
            }
            .font(.headline)
            
            Spacer()
            
            Text("Swipe to continue →")
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

// MARK: - Habit Selection Step
struct HabitSelectionStepView: View {
    @Binding var newHabitTitle: String
    @Binding var newHabitDescription: String
    let habits: [Habit]
    let onAddHabit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Add Your Daily Habits")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("What habits do you want to build? You'll need to complete these daily to unlock your apps.")
                .foregroundColor(.secondary)
            
            // Add Habit Form
            VStack(alignment: .leading, spacing: 12) {
                Text("Add a Habit")
                    .font(.headline)
                
                TextField("Habit name (e.g., 'Morning Walk')", text: $newHabitTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Description (optional)", text: $newHabitDescription)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Add Habit") {
                    onAddHabit()
                }
                .buttonStyle(.borderedProminent)
                .disabled(newHabitTitle.isEmpty)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Current Habits List
            if !habits.isEmpty {
                Text("Your Habits")
                    .font(.headline)
                
                ForEach(habits) { habit in
                    HStack {
                        Image(systemName: "target")
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading) {
                            Text(habit.title)
                                .fontWeight(.medium)
                            
                            if !habit.description.isEmpty {
                                Text(habit.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
            
            Spacer()
            
            if !habits.isEmpty {
                Text("Swipe to continue →")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding()
    }
}

// MARK: - Authorization Step
struct AuthorizationStepView: View {
    @ObservedObject var screenTimeManager: ScreenTimeManager
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "hand.raised.fill")
                .font(.system(size: 80))
                .foregroundColor(.orange)
            
            Text("Permission Required")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Earn It needs your permission to manage Screen Time settings and block apps.")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "shield.fill")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    Text("Block selected apps until habits are completed")
                }
                
                HStack {
                    Image(systemName: "checkmark.shield.fill")
                        .foregroundColor(.green)
                        .frame(width: 24)
                    Text("Automatically unlock apps when you complete habits")
                }
                
                HStack {
                    Image(systemName: "lock.shield.fill")
                        .foregroundColor(.red)
                        .frame(width: 24)
                    Text("Secure biometric authentication required")
                }
            }
            .font(.headline)
            
            VStack(spacing: 12) {
                if screenTimeManager.isAuthorized {
                    Text("✅ Permission granted!")
                        .font(.headline)
                        .foregroundColor(.green)
                    
                    Button("Continue") {
                        onContinue()
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                } else {
                    Button("Grant Permission") {
                        Task {
                            await screenTimeManager.requestAuthorization()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                    
                    if let error = screenTimeManager.authorizationError {
                        Text("Error: \(error)")
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - App Selection Step
struct AppSelectionStepView: View {
    @Binding var selectedApps: Set<UUID>
    @Binding var showingFamilyActivityPicker: Bool
    let onComplete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Choose Apps to Guard")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Select the apps you want to block until you complete your daily habits.")
                .foregroundColor(.secondary)
            
            VStack(spacing: 16) {
                // Real App Selection Button
                Button(action: {
                    showingFamilyActivityPicker = true
                }) {
                    HStack {
                        Image(systemName: "apps.iphone")
                        Text("Select Real Apps")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                
                Text("OR choose from popular apps below (for demo)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(GuardedApp.defaultApps) { app in
                    AppSelectionCard(
                        app: app,
                        isSelected: selectedApps.contains(app.id)
                    ) {
                        if selectedApps.contains(app.id) {
                            selectedApps.remove(app.id)
                        } else {
                            selectedApps.insert(app.id)
                        }
                    }
                }
            }
            
            Spacer()
            
            Button("Complete Setup") {
                onComplete()
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
        }
        .padding()
    }
}

// MARK: - App Selection Card
struct AppSelectionCard: View {
    let app: GuardedApp
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: app.iconName)
                    .font(.system(size: 32))
                    .foregroundColor(isSelected ? .white : .blue)
                
                Text(app.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    OnboardingView(appState: AppStateManager())
} 