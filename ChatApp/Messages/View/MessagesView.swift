//
//  MessagesView.swift
//  ChatApp
//
//  Created by ali cihan on 24.04.2024.
//

import SwiftUI

struct MessagesView: View {
    @ObservedObject var viewModel: MessageViewModel
    
    private var seenMessages: [Message] {
        return viewModel.getSeenMessages(selectedUser: viewModel.selectedUser)
    }
    
    private var unseenMessages: [Message] {
        return viewModel.getUnseenMessages(selectedUser: viewModel.selectedUser)
    }
    
    var body: some View {
        VStack{
            ScrollViewReader{ proxy in
                ScrollView(showsIndicators: false){
                    LazyVStack {
                        ForEach(seenMessages) { message in
                            Group {
                                VStack(alignment: .listRowSeparatorTrailing) {
                                    Text(message.content)
                                    Text(viewModel.messageTime(date: message.timestamp))
                                        .font(.footnote)
                                        .opacity(0.7)
                                }
                                .padding(10)
                                .background(message.userId != viewModel.selectedUser.userId ? .green2 : .orange1)
                                .clipShape(RoundedRectangle(cornerRadius: 10.0))
                            }
                            .frame(maxWidth: .infinity, alignment: message.userId != viewModel.selectedUser.userId ? .trailing : .leading)
                            .id(message.id)
                        }
                        if !unseenMessages.isEmpty {
                            ForEach(unseenMessages) { message in
                                Group {
                                    VStack(alignment: .listRowSeparatorTrailing) {
                                        Text(message.content)
                                        Text(viewModel.messageTime(date: message.timestamp))
                                            .font(.footnote)
                                            .opacity(0.7)
                                    }
                                    .padding()
                                    .background(.orange1)
                                    .clipShape(RoundedRectangle(cornerRadius: 10.0))
                                    
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .id(message.id)
                                .onAppear {
                                    viewModel.markMessagesAsSeen(messages: [message])
                                }
                            }
                        }
                    }
                }
                .onAppear {
                    proxy.scrollTo(unseenMessages.count > 0 ? unseenMessages.first?.id : seenMessages.last?.id)
                }
                .onChange(of: seenMessages.count + unseenMessages.count) {
                    proxy.scrollTo(unseenMessages.count > 0 ? unseenMessages.first?.id : seenMessages.last?.id)
                }
            }
            Spacer()
            HStack{
                TextField("Type a message...", text: $viewModel.message.content, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(4)
                Button {
                    viewModel.saveMessage(receiverId: viewModel.selectedUser.userId)
                } label: {
                    Image(systemName: "pencil.circle")
                        .font(.largeTitle)
                }
                .disabled(viewModel.message.content.count < 1)
            }
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    viewModel.viewPath.removeAll()
                }, label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        UserAvatar(user: viewModel.selectedUser, size: 30)
                    }
                })
                .foregroundStyle(.primary)
            }
            ToolbarItem(placement: .principal) {
                Text(viewModel.selectedUser.displayName)
                    .lineLimit(1)
            }
        }
        .navigationBarBackButtonHidden()
        .navigationTitle(viewModel.selectedUser.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .automatic)
        .toolbarBackground(.green1, for: .automatic)
    }
}

#Preview {
    NavigationStack {
        MessagesView(viewModel: MessageViewModel(test: true))
    }
}
