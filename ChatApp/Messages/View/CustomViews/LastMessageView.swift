//
//  LastMessageView.swift
//  ChatApp
//
//  Created by ali cihan on 5.06.2024.
//

import SwiftUI

struct LastMessageView: View {
    let message: Message
    let timestamp: String
    let user: AppUser
    let badgeNumber: Int
    
    init(input: (Message, String), user: AppUser, badgeNumber: Int) {
        self.message = input.0
        self.timestamp = input.1
        self.user = user
        self.badgeNumber = badgeNumber
    }
    var body: some View {
        VStack {
            HStack {
                Text(user.displayName.capitalized)
                    .bold()
                    .lineLimit(1)
                Spacer()
                Text(timestamp)
                    .font(.footnote)
            }
            HStack {
                Text(message.content)
                    .lineLimit(1)
                Spacer()
                if badgeNumber > 0 {
                    Group {
                    Text("\(badgeNumber)")
                        .font(.footnote)
                        .bold()
                    Image(systemName: "envelope.fill")
                    }
                    .foregroundStyle(.blue1)
                }
            }
        }
    }
}
