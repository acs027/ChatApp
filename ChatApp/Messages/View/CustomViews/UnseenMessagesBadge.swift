//
//  UnseenMessagesBadge.swift
//  ChatApp
//
//  Created by ali cihan on 5.06.2024.
//

import SwiftUI

struct UnseenMessagesBadge: View {
    let badgeNumber: Int
    
    var body: some View {
        if badgeNumber > 0 {
            ZStack {
                Circle()
                    .fill(.red)
                Text("\(badgeNumber)")
            }
        }
    }
}
