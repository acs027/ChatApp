//
//  ContentView.swift
//  ChatApp
//
//  Created by ali cihan on 18.04.2024.
//

import SwiftUI


struct ContentView: View {
    @StateObject var viewModel = MessageViewModel()
    
    var body: some View {
        NavigationStack(path: $viewModel.viewPath) {
            if viewModel.dataStatus["ready"]! {
                MessageListView(viewModel: viewModel)
                    .navigationDestination(for: AppView.self) { view in
                        switch view {
                        case .users:
                            UsersView(viewModel: viewModel)
                        case .contacts:
                            ContactsView(viewModel: viewModel)
                        case .messages:
                            MessagesView(viewModel: viewModel)
                        }
                    }
            } else {
                Spacer()
                ProgressView()
                Spacer()
            }
        }
        .padding()
        .toolbarBackground(.visible, for: .automatic)
        .toolbarBackground(.green1, for: .automatic)
        .foregroundStyle(.primary)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ContentView(viewModel: MessageViewModel(test: true))
}
