//
//  AppUser.swift
//  ChatApp
//
//  Created by ali cihan on 22.05.2024.
//

import Foundation

struct AppUser: Codable {
    var contactList: [String]
    var userId: String
    var displayName: String
    var photoURL: String
}

extension AppUser {
    static var empty: AppUser {
        AppUser(contactList: [], userId: "", displayName: "" , photoURL: "")
    }
}
