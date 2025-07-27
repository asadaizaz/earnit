//
//  PhotoCaptureView.swift
//  earnit
//
//  Created by Asad Aizaz on 2025-07-25.
//

import SwiftUI
import PhotosUI

struct PhotoCaptureView: View {
    @ObservedObject var appState: AppStateManager
    let habitId: UUID
    @Binding var isPresented: Bool
    
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var selectedImage: UIImage?
    @State private var showingConfirmation = false
    
    var habit: Habit? {
        appState.habits.first { $0.id == habitId }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "camera.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Add Proof Photo")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if let habit = habit {
                        Text("for \(habit.title)")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Instructions
                VStack(spacing: 16) {
                    Text("Take or select a photo to prove you completed this habit.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    Text("For MVP, any photo will work!")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                }
                
                // Photo Preview
                if let selectedImage = selectedImage {
                    VStack(spacing: 16) {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 200)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue, lineWidth: 2)
                            )
                        
                        Button("Complete Habit") {
                            showingConfirmation = true
                        }
                        .buttonStyle(.borderedProminent)
                        .font(.headline)
                    }
                } else {
                    // Photo Selection Buttons
                    VStack(spacing: 16) {
                        Button(action: { showingCamera = true }) {
                            HStack {
                                Image(systemName: "camera.fill")
                                Text("Take Photo")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                        
                        Button(action: { showingImagePicker = true }) {
                            HStack {
                                Image(systemName: "photo.on.rectangle")
                                Text("Choose from Library")
                            }
                            .font(.headline)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Proof Photo")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                }
            )
        }
        .sheet(isPresented: $showingCamera) {
            CameraView(selectedImage: $selectedImage)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .alert("Habit Completed!", isPresented: $showingConfirmation) {
            Button("Awesome!") {
                completeHabit()
                isPresented = false
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Great job! You've completed this habit for today.")
        }
    }
    
    private func completeHabit() {
        guard let selectedImage = selectedImage,
              let imageData = selectedImage.jpegData(compressionQuality: 0.8) else {
            return
        }
        
        appState.completeHabit(habitId: habitId, with: imageData)
    }
}

// MARK: - Camera View
struct CameraView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    @State var isPresented = true
    let appState = AppStateManager()
    appState.habits = [
        Habit(title: "Morning Walk", description: "Take a 30-minute walk outside")
    ]
    
    return PhotoCaptureView(
        appState: appState,
        habitId: appState.habits[0].id,
        isPresented: $isPresented
    )
} 