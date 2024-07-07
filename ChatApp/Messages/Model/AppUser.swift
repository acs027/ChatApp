//
//  AppUser.swift
//  ChatApp
//
//  Created by ali cihan on 22.05.2024.
//

import Foundation

struct AppUser: Codable, Equatable {
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

extension AppUser {
    static var mock_One: AppUser {
        AppUser(contactList: ["acs"], userId: "eken", displayName: "eken", photoURL: "")
    }
    static var mock_Two: AppUser {
        AppUser(contactList: ["eken"], userId: "acs", displayName: "acs", photoURL: "")
    }
}
