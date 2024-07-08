//
//  MessageViewModel.swift
//  ChatApp
//
//  Created by ali cihan on 24.04.2024.
//

import Foundation
import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

@MainActor
final class MessageViewModel: ObservableObject {
    @Published var message = Message.empty
    @Published var messages = [Message]() 
    {
        didSet {
            self.getMessagedUsers()
        }
    }
    @Published var currentUser = AppUser.empty
    @Published var allUsers = [AppUser]()
    
    @Published var messagedUsers = [AppUser]()
    
    @Published var selectedUser: AppUser = .empty
    @Published var viewPath: [AppView] = []
    
    @Published var dataStatus = ["users": false, "messages": false, "ready": false] {
        didSet {
            if dataStatus["users"]! && dataStatus["messages"]! && !dataStatus["ready"]! {
                getMessagedUsers()
                dataStatus["ready"] = true
            }
        }
    }
    
    @Published var user: User?
    private var db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
        
    init() {
        registerAuthStateHandler()
        
        $user
            .compactMap { $0 }
            .sink { user in
                self.message.userId = user.uid }
            .store(in: &cancellables)
    }
    
    init(test: Bool) {
        if test {
            self.messages = [Message.mock_One, Message.mock_Two]
            self.allUsers = [AppUser.mock_One, AppUser.mock_Two]
            self.messagedUsers = [AppUser.mock_Two]
            self.currentUser = AppUser.mock_One
            self.selectedUser = AppUser.mock_Two
            self.dataStatus["ready"] = true
        }
    }
    
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    
    func registerAuthStateHandler() {
        if authStateHandler == nil {
            authStateHandler = Auth.auth().addStateDidChangeListener { auth, user in
                self.user = user
                self.getUser()
                self.fetchAllUsers()
                self.fetchAllMessages()
            }
        }
    }
    
    func fetchAllUsers() {
        db.collection("users").getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else {
                return
            }
            let allUsers = documents.compactMap { document -> AppUser? in
                do{
                    return try document.data(as: AppUser.self)
                }
                catch {
                    print("User couldn't fetch.")
                    return nil
                }
            }
            self.allUsers = allUsers.sorted { $0.displayName.lowercased() < $1.displayName.lowercased() }
            self.dataStatus["users"] = true
        }
    }
    
    func fetchAllMessages() {
        guard let uid = user?.uid else { return }
        db.collection("messages").document(uid).collection(uid).addSnapshotListener { (snapshot, error) in
            guard let documents = snapshot?.documents else { return }
            self.messages = documents.compactMap { document -> Message? in
                do {
                    return try document.data(as: Message.self)
                }
                catch {
                    print("Error occured. Couldnt fetch messages!")
                    return nil
                }
            }
            self.messages.sort {
                $0.timestamp < $1.timestamp
            }
            self.dataStatus["messages"] = true
        }
    }
    
    func getUser() {
        guard let uid = user?.uid else { return }
        let docRef = db.collection("users").document(uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                do {
                    self.currentUser = try document.data(as: AppUser.self)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func getMessagedUsers() {
        var userIds = [String]()
        self.messages.reversed().forEach { message in
            if let personId = [message.userId, message.receiver].first(where: { $0 != user?.uid }) {
                if !userIds.contains(personId) {
                    userIds.append(personId)
                }
            }
        }
        self.messagedUsers = userIds.compactMap{ user -> AppUser? in
            return self.allUsers.first(where: {$0.userId == user})
        }
    }
    
    func getContacts() -> [AppUser] {
        return self.currentUser.contactList.compactMap { user in
            self.allUsers.first(where: { $0.userId == user })
        }
        .sorted{
            $0.displayName.lowercased() < $1.displayName.lowercased()
        }
    }
    
    func getSeenMessages(selectedUser: AppUser) -> [Message] {
        let seenMessages = self.messages.filter {
            selectedUser.userId == $0.receiver || (selectedUser.userId == $0.userId && $0.seen == true)
        }
        return seenMessages
    }
    
    func getUnseenMessages(selectedUser: AppUser) -> [Message] {
        let unseenMessages = self.messages.filter {
            $0.userId == selectedUser.userId && $0.seen == false
        }
        return unseenMessages
    }
    
    func addToContacts(userId: String) {
        guard let uid = user?.uid else { return }
        if !self.currentUser.contactList.contains(userId) {
            self.currentUser.contactList.append(userId)
            db.collection("users").document(uid).updateData(["contactList" : self.currentUser.contactList])
        }
    }
    
    func deleteMessages(selectedUser: AppUser) {
        guard let uid = user?.uid else { return }
        for message in self.messages {
            if [uid, selectedUser.userId].allSatisfy([message.receiver, message.userId].contains) {
                self.db.collection("messages").document(uid).collection(uid).document(message.id.uuidString).delete()
                self.db.collection("messages").document(selectedUser.userId).collection(selectedUser.userId).document(message.id.uuidString).delete()
            }
        }
    }
    
    func deleteFromContacts(selectedUser: AppUser) {
        guard let uid = user?.uid else { return }
        self.currentUser.contactList.removeAll {
            $0 == selectedUser.userId
        }
        db.collection("users").document(uid).updateData(["contactList" : self.currentUser.contactList])
        deleteMessages(selectedUser: selectedUser)
    }
    
    func findLastMessage(selectedUser: AppUser) -> (Message, String) {
        guard let lastMessage = self.messages.last(where: {$0.receiver == selectedUser.userId || $0.userId == selectedUser.userId})
        else { return (Message.empty, "")}
        let timestamp = self.relativeDate(date: lastMessage.timestamp)
        return (lastMessage, timestamp)
    }
            
    func relativeDate(date: Date) -> String {
        let relativeDateFormatter = DateFormatter()
        relativeDateFormatter.timeStyle = .none
        relativeDateFormatter.dateStyle = .medium
        relativeDateFormatter.locale = Locale(identifier: "en_GB")
        relativeDateFormatter.doesRelativeDateFormatting = true
        let relativeDate = relativeDateFormatter.string(from: date)
        
        if relativeDate == "Today" {
            relativeDateFormatter.dateStyle = .none
            relativeDateFormatter.timeStyle = .short
            relativeDateFormatter.doesRelativeDateFormatting = false
            return relativeDateFormatter.string(from: date)
        }
        return relativeDate
    }
    
    func messageTime(date: Date) -> String {
        let messageTimeFormatter = DateFormatter()
        messageTimeFormatter.timeStyle = .short
        messageTimeFormatter.dateStyle = .none
        messageTimeFormatter.locale = Locale(identifier: "en_GB")
        return messageTimeFormatter.string(from: date)
    }
    
    func filterUsers(searchString: String) -> [AppUser] {
        guard let uid = user?.uid else { return []}
        if searchString.count < 1 {
            return self.allUsers.filter { $0.userId != uid }
        }
        return self.allUsers.filter{ $0.displayName.lowercased().contains(searchString.lowercased()) && $0.userId != uid}
    }
    
    func filterContacts(searchString: String, contacts: [AppUser]) -> [AppUser] {
        if searchString.count < 1 {
            return contacts
        }
        return contacts.filter { $0.displayName.lowercased().contains(searchString.lowercased()) }
    }
        
    func saveMessage(receiverId: String) {
        self.message.id = UUID()
        if let user {
            self.message.userId = user.uid
        }
        self.message.timestamp = Date()
        self.message.receiver = receiverId
        
        guard let documentId = user?.uid else { return }
        do {
            try db.collection("messages").document(documentId).collection(documentId).document(self.message.id.uuidString).setData(from: self.message)
            try db.collection("messages").document(receiverId).collection(receiverId).document(self.message.id.uuidString).setData(from: self.message)
            self.message.content = ""
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func markMessagesAsSeen(messages: [Message]) {
        if messages.isEmpty {
            return
        }
        for message in messages {
            self.db.collection("messages").document(message.receiver).collection(message.receiver).document(message.id.uuidString).updateData(["seen": true])
        }
    }
}

enum AppView: Hashable {
    case users
    case contacts
    case messages
}

