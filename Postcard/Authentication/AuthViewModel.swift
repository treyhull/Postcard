import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    @Published var user: FirebaseAuth.User?
    @Published var isAuthenticated = false
    private let db = Firestore.firestore()
    
    init() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.isAuthenticated = user != nil
            self?.user = user
        }
    }
    
    func signUp(email: String, password: String, username: String, completion: @escaping (Result<FirebaseAuth.User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = result?.user {
                self.createUserInFirestore(user: user, username: username) { firestoreError in
                    if let firestoreError = firestoreError {
                        completion(.failure(firestoreError))
                    } else {
                        completion(.success(user))
                    }
                }
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = result?.user {
                completion(.success(user))
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    private func createUserInFirestore(user: FirebaseAuth.User, username: String, completion: @escaping (Error?) -> Void) {
        let newUser = AppUser(id: user.uid, username: username, email: user.email ?? "")
        do {
            try db.collection("users").document(user.uid).setData(from: newUser) { error in
                if let error = error {
                    print("Error adding user to Firestore: \(error.localizedDescription)")
                } else {
                    print("Successfully added user to Firestore")
                }
                completion(error)
            }
        } catch let error {
            print("Error encoding user for Firestore: \(error.localizedDescription)")
            completion(error)
        }
    }
}
