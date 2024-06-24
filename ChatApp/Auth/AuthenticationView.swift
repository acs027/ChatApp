//
//  AuthenticationView.swift
//  ChatApp
//
//  Created by ali cihan on 22.04.2024.
//

import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    
    var body: some View {
        VStack {
            switch viewModel.flow {
            case .login:
                LoginView()
                    .environmentObject(viewModel)
            case .signUp:
                SignupView()
                    .environmentObject(viewModel)
            }
        }
    }
}

#Preview {
    AuthenticationView()
}
