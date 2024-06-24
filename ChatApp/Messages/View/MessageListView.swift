//
//  MessageListView.swift
//  ChatApp
//
//  Created by ali cihan on 10.05.2024.
//

import SwiftUI

struct MessageListView: View {
    @StateObject var viewModel = MessageViewModel()
    @State var selectedUser = AppUser.empty
    
    @State var showingMessages = false
    @State var showingContacts = false
    @State var showingUsers = false
    
    var body: some View {
        VStack{
            if !viewModel.dataReady.allSatisfy({$0}) {
                ProgressView()
            }
            else {
                ZStack {
                    ScrollView(showsIndicators: false){
                        VStack {
                            ForEach(viewModel.messagedUsers, id:\.userId) { user in
                                HStack {
                                    UserAvatar(user: user, size: 50)
                                    
                                    VStack {
                                        HStack{
                                            Text(user.displayName.capitalized)
                                                .bold()
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            UnseenMessagesBadge(badgeNumber: viewModel.getUnseenMessages(selectedUser: user).count)
                                        }
                                        LastMessageView(input: viewModel.findLastMessage(selectedUser: user))
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedUser = user
                                    showingMessages.toggle()
                                }
                            }
                        }
                        .frame(maxHeight: .infinity, alignment: .topLeading)
                    }
                    
                    Button {
                        showingContacts.toggle()
                    } label: {
                        Image(systemName: "paperplane.circle.fill")
                            .font(.largeTitle)
                            .imageScale(.large)
                    }
                    
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Text("ChatApp")
                    .bold()
                    .font(.largeTitle)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingUsers.toggle()
                } label: {
                    Image(systemName: "person.2.fill")
                }
                .sheet(isPresented: $showingUsers) {
                    UsersView()
                        .environmentObject(viewModel)
                }
            }
        }
        .navigationDestination(isPresented: $showingMessages) {
            MessagesView(selectedUser: selectedUser, showingMessages: $showingMessages)
                .environmentObject(viewModel)
        }
        .navigationDestination(isPresented: $showingContacts) {
            ContactsView(showingContacs: $showingContacts)
                .environmentObject(viewModel)
        }
        .foregroundStyle(.primary)
        .toolbarBackground(.visible, for: .automatic)
        .toolbarBackground(.green1, for: .automatic)
        
    }
}

#Preview {
    MessageListView()
}
