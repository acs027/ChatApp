//
//  UsersView.swift
//  ChatApp
//
//  Created by ali cihan on 1.05.2024.
//

import SwiftUI

struct UsersView: View {
    @ObservedObject var viewModel: MessageViewModel
    @State private var searchString = ""
    
    private var users: [AppUser] {
        viewModel.filterUsers(searchString: searchString)
    }
    
    var body: some View {
        VStack {
            ZStack{
                RoundedRectangle(cornerRadius: 100.0)
                    .fill(.secondary)  
                HStack{
                    Image(systemName: "magnifyingglass")
                    TextField("", text: $searchString)
                }
                .padding()
            }
            .frame(height: 20)
            .padding()
            
            ScrollView(showsIndicators: false){
                ForEach(users, id:\.userId) { user in
                    HStack {
                        UserAvatar(user: user, size: 50)
                        Text(user.displayName.capitalized)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Image(systemName: "person.2.fill")
                            .foregroundStyle(.green1)
                            .opacity(viewModel.currentUser.contactList.contains(user.userId) ? 1 : 0)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.addToContacts(userId: user.userId)
                        viewModel.viewPath.removeLast()
                    }
                }
            }
        }
        .padding(.vertical)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    viewModel.viewPath.removeLast()
                } label: {
                    Image(systemName: "chevron.left")
                }
                .foregroundStyle(.primary)
            }
        }
        .navigationBarBackButtonHidden()
        .navigationTitle("Users")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .automatic)
        .toolbarBackground(.green1, for: .automatic)
    }
}

#Preview {
    NavigationStack {
        UsersView(viewModel: MessageViewModel(test: true))
    }
}
