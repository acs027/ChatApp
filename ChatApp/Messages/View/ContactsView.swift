//
//  ContactsView.swift
//  ChatApp
//
//  Created by ali cihan on 2.05.2024.
//

import SwiftUI

struct ContactsView: View {
    @ObservedObject var viewModel: MessageViewModel
    @State private var searchString = ""
    @State private var showingAlert = false
    @State private var selectedUser = AppUser.empty
    
    private var allContacts: [AppUser] {
        viewModel.getContacts()
    }
    
    private var filteredContacts: [AppUser] {
        viewModel.filterContacts(searchString: searchString, contacts: allContacts)
    }
    
    var body: some View {
        VStack{
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
                ForEach(filteredContacts, id:\.userId) { contact in
                    HStack {
                        UserAvatar(user: contact, size: 50)
                        Text(contact.displayName.capitalized)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    .frame(height: 50)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.selectedUser = contact
                        viewModel.viewPath.append(.messages)
                    }
                    .contextMenu(ContextMenu(menuItems: {
                        Button(role: .destructive) {
                            selectedUser = contact
                            showingAlert.toggle()
                        } label: {
                            HStack {
                                Text("Delete Contact and Messages")
                                Image(systemName: "trash")
                            }
                        }
                    }))
                    .alert("Delete \(selectedUser.displayName.capitalized)?", isPresented: $showingAlert) {
                        Button(role: .destructive) {
                            withAnimation {
                                self.viewModel.deleteFromContacts(selectedUser: selectedUser)
                            }
                            
                        } label: {
                            Text("Delete")
                        }
                    }
                }
            }
        }
        .padding(.vertical)
        .frame(maxHeight: .infinity, alignment: .topLeading)
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
        .navigationTitle("Contacts")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .automatic)
        .toolbarBackground(.green1, for: .automatic)
    }
}

#Preview {
    NavigationStack {
        ContactsView(viewModel: MessageViewModel(test: true))
    }
}
