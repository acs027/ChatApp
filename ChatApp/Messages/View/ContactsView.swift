//
//  ContactsView.swift
//  ChatApp
//
//  Created by ali cihan on 2.05.2024.
//

import SwiftUI

struct ContactsView: View {
    @EnvironmentObject var viewModel: MessageViewModel
    @State var selectedUser = AppUser.empty
    @Binding var showingContacs: Bool
    @State var showingMessages = false
    
    var allContacts: [AppUser] {
        return viewModel.currentUser.contactList.compactMap { user in
            viewModel.allUsers.first(where: { $0.userId == user })
        }
    }
    
    var body: some View {
        VStack{
            ScrollView(showsIndicators: false){
                ForEach(allContacts, id:\.userId) { contact in
                    HStack {
                        UserAvatar(user: contact, size: 50)
                        VStack {
                            Text(contact.displayName.capitalized)
                                .bold()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        self.selectedUser = contact
                        self.showingMessages.toggle()
                    }
                }
            }
            .navigationDestination(isPresented: $showingMessages) {
                MessagesView(selectedUser: selectedUser, showingMessages: $showingContacs)
                    .environmentObject(viewModel)
            }
        }
        .frame(maxHeight: .infinity, alignment: .topLeading)
    }
}
