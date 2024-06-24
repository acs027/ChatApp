//
//  ChatAppApp.swift
//  ChatApp
//
//  Created by ali cihan on 18.04.2024.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct ChatAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                AuthenticatedView {
                    Image(systemName: "ellipsis.message.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.green1)
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle())
                        .clipped()
                        .padding(4)
                    Text("Welcome to ChatApp!")
                        .font(.title)
                    Text("You need to be logged in to use this app.")
                } content: {
                    ContentView()
                }
            }
        }
    }
}
