//
//  UserProfileView.swift
//  ChatApp
//
//  Created by ali cihan on 22.04.2024.
//

import SwiftUI
import PhotosUI
import FirebaseAnalyticsSwift

struct UserProfileView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    @State var presentingConfirmationDialog = false
    
    @State var profilePhotoData: Data?
    @State var photosPickerItem: PhotosPickerItem?
    
    @State var displayName = ""
    
    @FocusState private var textFieldFocus: Bool
    
    private func deleteAccount() {
        Task {
            if await viewModel.deleteAccount() == true {
                dismiss()
            }
        }
    }
    
    private func signOut() {
        viewModel.signOut()
    }
    
    var body: some View {
        Form {
            Section {
                VStack {
                    HStack {
                        Spacer()
                        PhotosPicker(selection: $photosPickerItem, matching: .images) {
                            if profilePhotoData == nil {
                                AsyncImage(url: URL(string: viewModel.appUser.photoURL)) { phase in
                                    if let image = phase.image {
                                        image
                                            .resizable()
                                            .frame(width: 100 , height: 100)
                                            .scaledToFit()
                                            .clipShape(Circle())
                                    } else {
                                        Image(systemName: "person.fill")
                                            .resizable()
                                            .frame(width: 100 , height: 100)
                                            .aspectRatio(contentMode: .fit)
                                            .clipShape(Circle())
                                            .clipped()
                                            .padding(4)
                                            .overlay(Circle().stroke(Color.accentColor, lineWidth: 2))
                                    }
                                }
                            } else
                            {
                                Image(uiImage: UIImage(data: profilePhotoData!)!)
                                    .resizable()
                                    .frame(width: 100 , height: 100)
                                    .scaledToFit()
                                    .clipShape(Circle())
                            }
                        }
                        
                        Spacer()
                    }
                    Button(action: {}) {
                        Text("edit")
                    }
                }
            }
            .listRowBackground(Color(UIColor.systemGroupedBackground))
            Section("Display Name") {
                TextField(viewModel.appUser.displayName, text: $displayName)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .focused($textFieldFocus)
            }
            Section("Email") {
                Text(viewModel.user?.email ?? "")
            }
            Section {
                Button(role: .cancel, action: signOut) {
                    HStack {
                        Spacer()
                        Text("Sign out")
                        Spacer()
                    }
                }
            }
            Section {
                Button(role: .destructive, action: { presentingConfirmationDialog.toggle() }) {
                    HStack {
                        Spacer()
                        Text("Delete Account")
                        Spacer()
                    }
                }
            }
            Button {
                if (self.displayName != self.viewModel.appUser.displayName && self.displayName.count > 0) {
                    viewModel.changeDisplayName(displayName: self.displayName)
                    self.displayName = ""
                }
                if profilePhotoData != nil {
                    viewModel.uploadProfilePhoto(data: profilePhotoData!)
                    profilePhotoData = nil
                }
                self.textFieldFocus = false
            } label: {
                HStack {
                    Spacer()
                    Text("Save")
                    Spacer()
                }
            }
            .disabled(profilePhotoData == nil && self.displayName.count == 0)
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Deleting your account is permanent. Do you want to delete your account?",
                            isPresented: $presentingConfirmationDialog, titleVisibility: .visible) {
            Button("Delete Account", role: .destructive, action: deleteAccount)
            Button("Cancel", role: .cancel, action: { })
            
        }
                            .onChange(of: photosPickerItem) { _, _ in
                                Task {
                                    if let photosPickerItem,
                                       let data = try? await photosPickerItem.loadTransferable(type: Data.self) {
                                        profilePhotoData = data
                                    }
                                }
                            }
    }
}

#Preview {
    UserProfileView()
}
