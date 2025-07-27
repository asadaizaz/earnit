//
//  ProofSubmissionView.swift
//  earnit
//
//  Created by AI Assistant on 2025-07-25.
//

import SwiftUI

struct ProofSubmissionView: View {
    @ObservedObject var appState: AppStateManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showingPhotoCapture = false
    @State private var selectedHabitId: UUID?
    
    var incompleteHabits: [Habit] {
        appState.habits.filter { !$0.isCompletedToday }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "target")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Complete a Habit")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Choose which habit you'd like to complete to unlock your apps.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                if incompleteHabits.isEmpty {
                    // All habits completed
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.green)
                        
                        Text("All Habits Completed!")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Great job! Your apps should now be unlocked.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Close") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    // Show incomplete habits
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(incompleteHabits) { habit in
                                HabitProofCard(
                                    habit: habit,
                                    onSelect: {
                                        selectedHabitId = habit.id
                                        showingPhotoCapture = true
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Submit Proof")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .sheet(isPresented: $showingPhotoCapture) {
            if let habitId = selectedHabitId {
                PhotoCaptureView(
                    appState: appState,
                    habitId: habitId,
                    isPresented: $showingPhotoCapture
                )
            }
        }
    }
}

// MARK: - Habit Proof Card
struct HabitProofCard: View {
    let habit: Habit
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Habit Icon
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "camera.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
                
                // Habit Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(habit.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if !habit.description.isEmpty {
                        Text(habit.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    Text("Tap to add proof photo")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    let appState = AppStateManager()
    appState.habits = [
        Habit(title: "Morning Walk", description: "Take a 30-minute walk outside"),
        Habit(title: "Read 10 Pages", description: "Read at least 10 pages of a book")
    ]
    
    return ProofSubmissionView(appState: appState)
} 