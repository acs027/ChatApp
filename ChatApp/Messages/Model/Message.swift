//
//  Message.swift
//  ChatApp
//
//  Created by ali cihan on 24.04.2024.
//

import Foundation

struct Message: Codable, Identifiable {
    var id = UUID()
    var receiver: String
    var content: String
    var timestamp: Date
    var seen: Bool
    var userId: String
}

extension Message {
    static var empty: Message {
        Message(receiver: "bcs", content: "", timestamp: Date(), seen: false, userId: "")
    }
}

extension Message {
    static var mock_One: Message {
        Message(receiver: "acs", content: "Merhaba aCs", timestamp: Date(), seen: true, userId: "eken")
    }
    static var mock_Two: Message {
        Message(receiver: "eken", content: "Merhaba Eken", timestamp: Date(), seen: true, userId: "acs")
    }
}
