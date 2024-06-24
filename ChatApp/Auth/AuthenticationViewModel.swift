//
//  AuthenticationViewModel.swift
//  ChatApp
//
//  Created by ali cihan on 22.04.2024.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift
import FirebaseFirestore
import FirebaseStorage

enum AuthenticationState {
    case unauthenticated
    case authenticating
    case authenticated
}

enum AuthenticationFlow {
    case login
    case signUp
}

@MainActor
class AuthenticationViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    
    @Published var flow: AuthenticationFlow = .login
    
    @Published var isValid: Bool = false
    @Published var authenticationState: AuthenticationState = .unauthenticated
    @Published var errorMessage: String = ""
    @Published var user: User?
    
    private var db = Firestore.firestore()
    
    @Published var appUser = AppUser.empty
    
    init() {
        registerAuthStateHandler()
        
        $flow
            .combineLatest($email, $password, $confirmPassword )
            .map { flow, email, password, confirmPassword in
                flow == .login
                ? !(email.isEmpty || password.isEmpty)
                : !(email.isEmpty || password.isEmpty || confirmPassword.isEmpty)
            }
            .assign(to: &$isValid)
    }
    
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    
    func registerAuthStateHandler() {
        if authStateHandler == nil {
            authStateHandler = Auth.auth().addStateDidChangeListener { auth, user in
                self.user = user
                self.authenticationState = user == nil ? .unauthenticated : .authenticated
                self.getUser()
                self.email = user?.email ?? ""
            }
        }
    }
    
    func switchFlow() {
        flow = flow == .login ? .signUp : .login
        errorMessage = ""
    }
    
    private func wait() async {
        do {
            print("Wait")
            try await Task.sleep(nanoseconds: 1_000_000_000)
            print("Done")
        }
        catch{ }
    }
    
    func reset() {
        flow = .login
        email = ""
        password = ""
        confirmPassword = ""
    }
}

extension AuthenticationViewModel {
    func signInWithEmailPassword() async -> Bool {
        authenticationState = .authenticating
        do {
            try await Auth.auth().signIn(withEmail: self.email, password: self.password)
            return true
        }
        catch {
            print(error.localizedDescription)
            errorMessage = error.localizedDescription
            authenticationState = .unauthenticated
            return false
        }
    }
    
    func signUpWithEmailPassword() async -> Bool {
        authenticationState = .authenticating
        do {
            try await Auth.auth().createUser(withEmail: self.email, password: self.password)
            return true
        }
        catch {
            print(error.localizedDescription)
            errorMessage = error.localizedDescription
            authenticationState = .unauthenticated
            return false
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        }
        catch {
            print(error)
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteAccount() async -> Bool {
        do {
            try await user?.delete()
            return true
        }
        catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    enum AuthenticationError: Error {
        case tokenError(message: String)
    }
}

extension AuthenticationViewModel {
    func signInWithGoogle() async -> Bool {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("No client ID found in Firebase configuration")
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            print("There is no root view controller")
            return false
        }
        
        do {
            let userAuthentication = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            
            let user = userAuthentication.user
            guard let idToken = user.idToken else { throw AuthenticationError.tokenError(message: "ID token missing")}
            let accessToken = user.accessToken
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString,
                                                           accessToken: accessToken.tokenString)
            
            let result = try await Auth.auth().signIn(with: credential)
            let firebaseUser = result.user
            print("User \(firebaseUser.uid) signed in with email \(firebaseUser.email ?? "unknown")")
            return true
        }
        catch {
            print(error.localizedDescription)
            self.errorMessage = error.localizedDescription
            return false
        }
    }
}

extension AuthenticationViewModel {
    func getUser() {
        
        guard let uid = user?.uid else { return }
        let docRef = db.collection("users").document(uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                do {
                    self.appUser = try document.data(as: AppUser.self)
                } catch {
                    print(error.localizedDescription)
                }
            } else {
                let displayName = self.user?.displayName ?? ""
                let photoURL = self.user?.photoURL?.absoluteString ?? ""
                let contactList = [String]()
                self.appUser = AppUser(contactList: contactList, userId: uid, displayName: displayName, photoURL: photoURL)
                do {
                    try docRef.setData(from: self.appUser)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func changeDisplayName(displayName: String) {
        guard let uid = user?.uid else { return }
        db.collection("users").document(uid).updateData(["displayName" : displayName])
        self.appUser.displayName = displayName
    }
    
    func uploadProfilePhoto(data: Data) {
        guard let uid = user?.uid else { return }
        guard let cropAndResize = UIImage(data: data)?.cropAndResize(to: 1024) else { return }
        let imgData = cropAndResize.jpegData(compressionQuality: 1.0)
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        let profilePhotoRef = storageRef.child("images/\(uid).jpg")

        // Upload the file to the path "images/rivers.jpg"
        let _ = profilePhotoRef.putData(imgData!, metadata: nil) { (metadata, error) in
          guard let metadata = metadata else {
            // Uh-oh, an error occurred!
              print("Error occured")
            return
          }
          // Metadata contains file metadata such as size, content-type.
          let _ = metadata.size
          // You can also access to download URL after upload.
            profilePhotoRef.downloadURL { (url, error) in
            guard let downloadURL = url else {
              // Uh-oh, an error occurred!
                print("Error occurred!")
              return
            }
                self.db.collection("users").document(uid).updateData(["photoURL" : downloadURL.absoluteString])
                self.appUser.photoURL = downloadURL.absoluteString
          }
        }
    }
}
