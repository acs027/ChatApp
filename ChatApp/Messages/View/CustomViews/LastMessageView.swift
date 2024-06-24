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
    
    init(input: (Message, String)) {
        self.message = input.0
        self.timestamp = input.1
    }
    var body: some View {
        HStack {
            Text(message.content)
            Spacer()
            Text(timestamp)
        }
    }
}
