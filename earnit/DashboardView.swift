//
//  DashboardView.swift
//  earnit
//
//  Created by Asad Aizaz on 2025-07-25.
//

import SwiftUI

struct DashboardView: View {
    @ObservedObject var appState: AppStateManager
    @State private var showingPhotoCapture = false
    @State private var selectedHabitId: UUID?
    
    var allHabitsCompleted: Bool {
        !appState.habits.isEmpty && appState.habits.allSatisfy { $0.isCompletedToday }
    }
    
    var body: some View {
        TabView {
            // Main Dashboard Tab
            mainDashboardView
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Dashboard")
                }
            
            // ScreenTime Demo Tab
            ScreenTimeDemoView()
                .tabItem {
                    Image(systemName: "iphone.and.arrow.forward")
                    Text("ScreenTime")
                }
        }
        .sheet(isPresented: $showingPhotoCapture) {
            if let habitId = selectedHabitId {
                PhotoCaptureView(
                    appState: appState,
                    habitId: habitId,
                    isPresented: $showingPhotoCapture
                )
            } else {
                // Fallback view if habitId is nil
                Text("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
                    .onAppear {
                        // Close the sheet if no habit is selected
                        showingPhotoCapture = false
                    }
            }
        }

    }
    
    private var mainDashboardView: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                headerView
                
                // Progress Section
                progressSection
                
                // Habits List
                habitsSection
                
                Spacer()
                
                // Status Footer
                statusFooter
            }
            .padding()
            .navigationTitle("Earn It")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                appState.checkForNewDay()
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Today's Progress")
                .font(.title2)
                .fontWeight(.semibold)
            
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.secondary)
                Text(Date().formatted(date: .abbreviated, time: .omitted))
                    .foregroundColor(.secondary)
            }
            .font(.caption)
        }
    }
    
    private var progressSection: some View {
        VStack(spacing: 12) {
            // Progress Ring
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 8)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: progressPercentage)
                    .stroke(
                        allHabitsCompleted ? Color.green : Color.blue,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: progressPercentage)
                
                VStack {
                    Text("\(completedHabitsCount)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("of \(appState.habits.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Status Text
            Text(allHabitsCompleted ? "🎉 All habits completed!" : "Keep going!")
                .font(.headline)
                .foregroundColor(allHabitsCompleted ? .green : .primary)
            
            // Apps Status
            if allHabitsCompleted {
                Text("Your apps are now unlocked")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("Complete your habits to unlock apps")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var habitsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Habits")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if appState.habits.isEmpty {
                emptyHabitsView
            } else {
                ForEach(appState.habits) { habit in
                    HabitCard(
                        habit: habit,
                        onCompleteHabit: {
                            // Ensure state is set properly before showing sheet
                            selectedHabitId = habit.id
                            DispatchQueue.main.async {
                                showingPhotoCapture = true
                            }
                        }
                    )
                }
            }
        }
    }
    
    private var emptyHabitsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "target")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No habits yet")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Complete the onboarding again to add habits")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var statusFooter: some View {
        VStack(spacing: 8) {
            if !appState.guardedApps.isEmpty {
                Text("Guarded Apps")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    ForEach(appState.guardedApps.prefix(4)) { app in
                        VStack {
                            Image(systemName: app.iconName)
                                .font(.title2)
                                .foregroundColor(app.isBlocked ? .red : .green)
                            
                            Text(app.name)
                                .font(.caption2)
                                .lineLimit(1)
                        }
                        .opacity(app.isBlocked ? 0.6 : 1.0)
                    }
                    
                    if appState.guardedApps.count > 4 {
                        Text("+\(appState.guardedApps.count - 4)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    private var progressPercentage: CGFloat {
        guard !appState.habits.isEmpty else { return 0 }
        return CGFloat(completedHabitsCount) / CGFloat(appState.habits.count)
    }
    
    private var completedHabitsCount: Int {
        appState.habits.filter { $0.isCompletedToday }.count
    }
    

}

// MARK: - Habit Card
struct HabitCard: View {
    let habit: Habit
    let onCompleteHabit: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Status Icon
            ZStack {
                Circle()
                    .fill(habit.isCompletedToday ? Color.green : Color(.systemGray5))
                    .frame(width: 40, height: 40)
                
                Image(systemName: habit.isCompletedToday ? "checkmark" : "camera.fill")
                    .foregroundColor(habit.isCompletedToday ? .white : .secondary)
                    .font(.system(size: 16, weight: .medium))
            }
            
            // Habit Info
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.title)
                    .font(.headline)
                    .foregroundColor(habit.isCompletedToday ? .secondary : .primary)
                
                if !habit.description.isEmpty {
                    Text(habit.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                if habit.isCompletedToday, let completedAt = habit.completedAt {
                    Text("Completed at \(completedAt.formatted(date: .omitted, time: .shortened))")
                        .font(.caption2)
                        .foregroundColor(.green)
                }
            }
            
            Spacer()
            
            // Action Button
            if !habit.isCompletedToday {
                Button("Add Proof") {
                    onCompleteHabit()
                }
                .buttonStyle(.borderedProminent)
                .font(.caption)
            } else {
                Image(systemName: "photo.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .opacity(habit.isCompletedToday ? 0.8 : 1.0)
    }
}

#Preview {
    let appState = AppStateManager()
    appState.habits = [
        Habit(title: "Morning Walk", description: "Take a 30-minute walk outside"),
        Habit(title: "Read 10 Pages", description: "Read at least 10 pages of a book")
    ]
    
    return DashboardView(appState: appState)
} 