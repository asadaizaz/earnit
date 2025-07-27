//
//  earnitApp.swift
//  earnit
//
//  Created by Asad Aizaz on 2025-07-25.
//

import SwiftUI

@main
struct earnitApp: App {
    @StateObject private var appState = AppStateManager()
    @StateObject private var screenTimeManager: ScreenTimeManager
    
    init() {
        let appState = AppStateManager()
        let screenTimeManager = ScreenTimeManager(appState: appState)
        
        _appState = StateObject(wrappedValue: appState)
        _screenTimeManager = StateObject(wrappedValue: screenTimeManager)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(screenTimeManager)
                .onAppear {
                    setupApp()
                }
                .onOpenURL { url in
                    handleIncomingURL(url)
                }
        }
    }
    
    private func setupApp() {
        // Perform any initial setup
        appState.checkForNewDay()
    }
    
    private func handleIncomingURL(_ url: URL) {
        // Handle custom URL scheme for shield redirection
        if url.scheme == "earnit" {
            switch url.host {
            case "proof-submission":
                // Navigate to proof submission
                appState.shouldNavigateToProof = true
            default:
                break
            }
        }
    }
}
