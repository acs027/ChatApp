//
//  MessageListView.swift
//  ChatApp
//
//  Created by ali cihan on 10.05.2024.
//

import SwiftUI

struct MessageListView: View {
    @ObservedObject var viewModel: MessageViewModel
    @State private var showingAlert = false
    @State private var selectedUser = AppUser.empty
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false){
                VStack {
                    ForEach(viewModel.messagedUsers, id:\.userId) { user in
                        HStack {
                            UserAvatar(user: user, size: 50)
                            LastMessageView(input: viewModel.findLastMessage(selectedUser: user), user: user, badgeNumber: viewModel.getUnseenMessages(selectedUser: user).count)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.selectedUser = user
                            viewModel.viewPath.append(.messages)
                        }
                        .contextMenu(ContextMenu(menuItems: {
                            Button(role: .destructive) {
                                selectedUser = user
                                showingAlert.toggle()
                            } label: {
                                HStack {
                                    Text("Delete Messages")
                                    Image(systemName: "trash")
                                }
                            }
                        }))
                        .alert("Delete messages?", isPresented: $showingAlert) {
                            Button(role: .destructive) {
                                withAnimation {
                                    self.viewModel.deleteMessages(selectedUser: selectedUser)
                                }
                            } label: {
                                Text("Delete")
                            }
                        }
                    }
                }
            }            
            Button {
                viewModel.viewPath.append(.contacts)
            } label: {
                Image(systemName: "paperplane.circle.fill")
                    .font(.largeTitle)
                    .imageScale(.large)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Text("ChatApp")
                    .font(.largeTitle)
                    .bold()
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.viewPath.append(.users)
                } label: {
                    Image(systemName: "person.2.fill")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        MessageListView(viewModel: MessageViewModel(test: true))
    }
}
