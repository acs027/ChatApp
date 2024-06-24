//
//  UserAvatar.swift
//  ChatApp
//
//  Created by ali cihan on 5.06.2024.
//

import SwiftUI

struct UserAvatar: View {
    let user: AppUser
    let size: CGFloat
    
    var body: some View {
        AsyncImage(url: URL(string: user.photoURL)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle")
                        .resizable()
                        .scaledToFit()
                }
        }
        .frame(width: size, height: size)
    }
}
