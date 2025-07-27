//
//  FamilyActivityPickerView.swift
//  earnit
//
//  Created by AI Assistant on 2025-07-25.
//

import SwiftUI
import FamilyControls

struct FamilyActivityPickerView: View {
    @State private var selection = FamilyActivitySelection()
    @Binding var isPresented: Bool
    let onSelectionComplete: (FamilyActivitySelection) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    Image(systemName: "apps.iphone")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Select Apps to Guard")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Choose which apps you want to block until you complete your daily habits.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                FamilyActivityPicker(selection: $selection)
                    .frame(maxHeight: 400)
                
                Spacer()
                
                VStack(spacing: 12) {
                    if !selection.applications.isEmpty || !selection.categories.isEmpty || !selection.webDomains.isEmpty {
                        Text("You've selected apps and categories to guard")
                            .font(.caption)
                            .foregroundColor(.green)
                            .multilineTextAlignment(.center)
                    } else {
                        Text("Select apps, categories, or websites to guard")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button("Save Selection") {
                        onSelectionComplete(selection)
                        isPresented = false
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                    .disabled(selection.applications.isEmpty && selection.categories.isEmpty && selection.webDomains.isEmpty)
                }
                .padding()
            }
            .navigationTitle("App Selection")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Cancel") {
                    isPresented = false
                }
            )
        }
    }
}

#Preview {
    @State var isPresented = true
    
    return FamilyActivityPickerView(
        isPresented: $isPresented,
        onSelectionComplete: { selection in
            print("Selected apps: \(selection)")
        }
    )
} 