//
//  MessagesView.swift
//  ChatApp
//
//  Created by ali cihan on 24.04.2024.
//

import SwiftUI

struct MessagesView: View {
    @EnvironmentObject var viewModel: MessageViewModel
    
    @State var selectedUser: AppUser
    @Binding var showingMessages: Bool
    
    private var seenMessages: [Message] {
        return viewModel.getSeenMessages(selectedUser: selectedUser)
    }
    
    private var unseenMessages: [Message] {
        return viewModel.getUnseenMessages(selectedUser: selectedUser)
    }
    
    
    
    var body: some View {
        VStack{
            ScrollViewReader{ proxy in
                ScrollView(showsIndicators: false){
                    ForEach(seenMessages) { message in
                        Group {
                            Text(message.content)
                                .padding()
                                .background(message.userId != selectedUser.userId ? .green2 : .orange1)
                                .clipShape(RoundedRectangle(cornerRadius: 10.0))
                                .frame(maxWidth: .infinity, alignment: message.userId != selectedUser.userId ? .trailing : .leading)
                        }
                        .id(message.id)
                    }
                    
                    if !unseenMessages.isEmpty {
                        ZStack {
                            RoundedRectangle(cornerRadius: 25.0)
                                .fill(.green)
                            Text("Unread Messages")
                        }
                        ForEach(unseenMessages) { message in
                            Group {
                                Text(message.content)
                                    .padding()
                                    .background(message.userId != selectedUser.userId ? .green2 : .orange1)
                                    .clipShape(RoundedRectangle(cornerRadius: 10.0))
                                    .frame(maxWidth: .infinity, alignment: message.userId != selectedUser.userId ? .trailing : .leading)
                            }
                            .onAppear {
                                viewModel.markMessageAsSeen(message: message)
                            }
                        }
                        
                    }
                }
//                .onChange(of: seenMessages.count, {
//                    proxy.scrollTo(seenMessages.last?.id)
//                })
                .onAppear {
                    proxy.scrollTo(seenMessages.last?.id)
                }
            }
            
            Spacer()
            HStack{
                TextField("Type a message...", text: $viewModel.message.content, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .lineLimit(4)
                Button {
                    viewModel.saveMessage(receiverId: selectedUser.userId)
                } label: {
                    Image(systemName: "pencil.circle")
                }
                .disabled(viewModel.message.content.count < 1)
            }.padding(5)
            
        }
        .padding()
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    showingMessages = false
                } label: {
                    Text("Back")
                }
            }
            ToolbarItem(placement: .principal) {
                UserAvatar(user: selectedUser, size: 30)
            }
        }
        .foregroundStyle(.primary)
    }
    
}

//#Preview {
//    MessagesView()
//}
