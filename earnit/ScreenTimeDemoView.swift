//
//  ScreenTimeDemoView.swift
//  earnit
//
//  Created by Asad Aizaz on 2025-07-25.
//

import SwiftUI

struct ScreenTimeDemoView: View {
    @EnvironmentObject var appState: AppStateManager
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @State private var showingBlockingDemo = false
    @State private var selectedApp = "Instagram"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "iphone.and.arrow.forward")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("ScreenTime Integration")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("MVP Demo - How App Blocking Would Work")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Info Section
                VStack(alignment: .leading, spacing: 16) {
                    InfoRow(
                        icon: "shield.fill",
                        title: "Real ScreenTime API",
                        description: "In production, this would use Apple's ScreenTime API to actually block apps."
                    )
                    
                    InfoRow(
                        icon: "camera.fill",
                        title: "Photo Verification",
                        description: "Users take photos as proof of completing habits."
                    )
                    
                    InfoRow(
                        icon: "checkmark.circle.fill",
                        title: "Auto Unlock",
                        description: "Apps automatically unlock when all daily habits are completed."
                    )
                    
                    InfoRow(
                        icon: "arrow.clockwise",
                        title: "Daily Reset",
                        description: "Habits reset each day, ensuring consistent engagement."
                    )
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                
                // Demo Section
                VStack(spacing: 16) {
                    Text("Try the Demo")
                        .font(.headline)
                    
                    Text("See how blocking would work when you try to access a guarded app:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    // Simulated App Icons
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(appState.guardedApps.prefix(6)) { app in
                            Button(action: {
                                selectedApp = app.name
                                showingBlockingDemo = true
                            }) {
                                VStack(spacing: 8) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(app.isBlocked ? Color.red.opacity(0.2) : Color.green.opacity(0.2))
                                            .frame(width: 60, height: 60)
                                        
                                        Image(systemName: app.iconName)
                                            .font(.title2)
                                            .foregroundColor(app.isBlocked ? .red : .green)
                                        
                                        if app.isBlocked {
                                            Image(systemName: "lock.fill")
                                                .font(.caption)
                                                .foregroundColor(.white)
                                                .background(Circle().fill(Color.red).frame(width: 20, height: 20))
                                                .offset(x: 20, y: -20)
                                        }
                                    }
                                    
                                    Text(app.name)
                                        .font(.caption2)
                                        .lineLimit(1)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    Text(screenTimeManager.isBlockingActive ? "🔒 Apps are currently blocked" : "🎉 Apps are unlocked!")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(screenTimeManager.isBlockingActive ? .red : .green)
                }
                
                Spacer()
                
                // Note
                Text("Note: Full ScreenTime integration requires special Apple entitlements and review process.")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .padding()
            .navigationTitle("ScreenTime Demo")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingBlockingDemo) {
            BlockingOverlayView(
                appName: selectedApp,
                message: screenTimeManager.showBlockingMessage(for: selectedApp),
                onOpenEarnIt: {
                    // This would normally open the main app
                    print("Would redirect to Earn It main app")
                },
                isPresented: $showingBlockingDemo
            )
        }
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    let appState = AppStateManager()
    appState.guardedApps = GuardedApp.defaultApps
    appState.habits = [
        Habit(title: "Morning Walk", description: "Take a 30-minute walk"),
        Habit(title: "Read 10 Pages", description: "Read at least 10 pages")
    ]
    
    let screenTimeManager = ScreenTimeManager(appState: appState)
    
    return ScreenTimeDemoView()
        .environmentObject(appState)
        .environmentObject(screenTimeManager)
} 