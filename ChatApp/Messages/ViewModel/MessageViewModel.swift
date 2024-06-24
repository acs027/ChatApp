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
class MessageViewModel: ObservableObject {
    @Published var message = Message.empty
    @Published var messages = [Message]()
    @Published var currentUser = AppUser.empty
//    @Published var allContacts = [AppUser]()
    @Published var allUsers = [AppUser]()
    
    @Published var messagedUsers = [AppUser]()
    
    @Published var dataReady = [false, false, false] {
        didSet {
            if dataReady[0] && dataReady[1] && !dataReady[2] {
                self.getMessagedUsers()
                self.dataReady[2] = true
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
    
    func addToContacts(userId: String) {
        guard let uid = user?.uid else { return }
        if !self.currentUser.contactList.contains(userId) {
            self.currentUser.contactList.append(userId)
            db.collection("users").document(uid).updateData(["contactList" : self.currentUser.contactList])
        }
    }
    
    func fetchAllUsers() {
        db.collection("users").getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else {
                return
            }
            self.allUsers = documents.compactMap { document -> AppUser? in
                do{
                    return try document.data(as: AppUser.self)
                }
                catch {
                    print("User couldn't fetch.")
                    return nil
                }
            }
            self.dataReady[1] = true
        }
    }
    
    func findLastMessage(selectedUser: AppUser) -> (Message, String) {
        guard let lastMessage = self.messages.last(where: {$0.receiver == selectedUser.userId || $0.userId == selectedUser.userId})
        else { return (Message.empty, "")}
        let timestamp = self.relativeDate(date: lastMessage.timestamp)
        return (lastMessage, timestamp)
    }
    
    func fetchAllMessages() {
        guard let uid = user?.uid else { return }
        
        db.collection("messages").document(uid).collection(uid).addSnapshotListener { (snapshot, error) in
            self.messages.removeAll()
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
            self.dataReady[0] = true
            self.getMessagedUsers()
        }
    }
    
    func getMessagedUsers() {
        var userIds = [String]()
        self.messages.reversed().forEach { message in
            if message.receiver != self.user?.uid && !userIds.contains(message.receiver) {
                userIds.append(message.receiver)
            } else if message.userId != self.user?.uid && !userIds.contains(message.userId) {
                userIds.append(message.userId)
            }
        }
        self.messagedUsers = userIds.compactMap{ user -> AppUser? in
                return self.allUsers.first(where: {$0.userId == user})
        }
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
    
    func filterUsers(searchString: String) -> [AppUser] {
        guard let uid = user?.uid else { return []}
        if searchString.count < 1 {
            return self.allUsers.filter { $0.userId != uid }
        }
        return self.allUsers.filter{ $0.displayName.lowercased().contains(searchString.lowercased()) && $0.userId != uid}
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
            print("save message")
            print(error.localizedDescription)
        }
    }
    
    func getSeenMessages(selectedUser: AppUser) -> [Message] {
        let seenMessages = self.messages.filter {
            $0.receiver == selectedUser.userId || ($0.userId == selectedUser.userId && $0.seen == true)
        }
        return seenMessages
    }
    
    func getUnseenMessages(selectedUser: AppUser) -> [Message] {
        let unseenMessages = self.messages.filter {
            $0.userId == selectedUser.userId && $0.seen == false
        }
        return unseenMessages
    }
    
    func markMessageAsSeen(message: Message) {
        var message = message
        message.seen = true
        do {
//            try db.collection("messages").document(message.receiver).collection(message.receiver).document(message.id.uuidString).setData(from: message)
            db.collection("messages").document(message.receiver).collection(message.receiver).document(message.id.uuidString).updateData(["seen": true])
            
//            try db.collection("messages").document(message.userId).collection(message.userId).document(message.id.uuidString).setData(from: message)
            db.collection("messages").document(message.userId).collection(message.userId).document(message.id.uuidString).updateData(["seen" : true])
        }
//        catch {
//            print("mark message as seen error")
//            print(error.localizedDescription)
//        }
    }
    
}

