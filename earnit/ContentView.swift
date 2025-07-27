//
//  ContentView.swift
//  earnit
//
//  Created by Asad Aizaz on 2025-07-25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppStateManager
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @State private var showingProofSubmission = false
    
    var body: some View {
        Group {
            if appState.isOnboardingComplete {
                DashboardView(appState: appState)
            } else {
                OnboardingView(appState: appState)
            }
        }
        .onAppear {
            // Request camera permission when needed
            requestCameraPermission()
        }
        .onChange(of: appState.shouldNavigateToProof) { shouldNavigate in
            if shouldNavigate {
                showingProofSubmission = true
                appState.shouldNavigateToProof = false
            }
        }
        .sheet(isPresented: $showingProofSubmission) {
            ProofSubmissionView(appState: appState)
        }
    }
    
    private func requestCameraPermission() {
        // Camera permission will be requested when camera is accessed
        // This is handled automatically by the system
    }
}

#Preview {
    let appState = AppStateManager()
    let screenTimeManager = ScreenTimeManager(appState: appState)
    
    return ContentView()
        .environmentObject(appState)
        .environmentObject(screenTimeManager)
}
