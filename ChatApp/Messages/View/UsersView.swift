//
//  UsersView.swift
//  ChatApp
//
//  Created by ali cihan on 1.05.2024.
//

import SwiftUI

struct UsersView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: MessageViewModel
    
    @State private var searchString = ""
    
    private var users: [AppUser] {
        viewModel.filterUsers(searchString: searchString)
    }
    
    var body: some View {
        Button{
            dismiss()
        } label: {
            HStack{
                Image(systemName: "arrowshape.down.fill")
                Text("Back")
                Image(systemName: "arrowshape.down.fill")
            }
        }
        
        
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
                    VStack {
                        Text(user.displayName.capitalized)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.addToContacts(userId: user.userId)
                    dismiss()
                }
            }
        }
    }
}

//#Preview {
//    UsersView()
//}
