//
//  AuthenticatedView.swift
//  ChatApp
//
//  Created by ali cihan on 22.04.2024.
//

import SwiftUI

extension AuthenticatedView where Unauthenticated == EmptyView {
    init(@ViewBuilder content: @escaping () -> Content) {
        self.unauthenticated = nil
        self.content = content
    }
}

struct AuthenticatedView<Content, Unauthenticated>: View where Content: View, Unauthenticated: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @State private var presentingLoginScreen = false
    @State private var presentingProfileScreen = false
    
    var unauthenticated: Unauthenticated?
    @ViewBuilder var content: () -> Content
    
    public init(unauthenticated: Unauthenticated?, @ViewBuilder content: @escaping () -> Content) {
        self.unauthenticated = unauthenticated
        self.content = content
    }
    
    public init(@ViewBuilder unauthenticated: @escaping () -> Unauthenticated, @ViewBuilder content: @escaping () -> Content) {
        self.unauthenticated = unauthenticated()
        self.content = content
    }
    
    var body: some View {
        switch viewModel.authenticationState {
        case .unauthenticated, .authenticating:
            VStack {
                if let unauthenticated {
                    unauthenticated
                }
                else {
                    Text("You're not logged in.")
                }
                Button("Tap here to log in") {
                    viewModel.reset()
                    presentingLoginScreen.toggle()
                }
            }
            .sheet(isPresented: $presentingLoginScreen) {
                AuthenticationView()
                    .environmentObject(viewModel)
            }
        case .authenticated:
            ZStack {
                content()
                HStack {
                    Button {
                        presentingProfileScreen.toggle()
                    } label: {
                            UserAvatar(user: viewModel.appUser, size: 45)
                    }
                    .foregroundStyle(.primary)
                    Spacer()
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding()
            }
            .sheet(isPresented: $presentingProfileScreen) {
                NavigationStack {
                    UserProfileView()
                        .environmentObject(viewModel)
                }
            }
        }
    }
}

//#Preview {
//    AuthenticatedView()
//}
