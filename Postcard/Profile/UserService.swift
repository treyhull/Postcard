import Firebase
import FirebaseFirestore

class UserService: ObservableObject {
    private let db = Firestore.firestore()
    
    func searchUsers(withPrefix prefix: String, completion: @escaping ([AppUser]) -> Void) {
        guard !prefix.isEmpty else {
            print("Search prefix is empty")
            completion([])
            return
        }
        
        let endPrefix = prefix.appending("\u{f8ff}")
        
        print("Searching for users with prefix: \(prefix)")
        
        db.collection("users")
            .whereField("username", isGreaterThanOrEqualTo: prefix)
            .whereField("username", isLessThan: endPrefix)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error.localizedDescription)")
                    completion([])
                } else {
                    let users = querySnapshot?.documents.compactMap { document -> AppUser? in
                        do {
                            let user = try document.data(as: AppUser.self)
                            print("Found user: \(user.username)")
                            return user
                        } catch {
                            print("Error decoding user: \(error.localizedDescription)")
                            return nil
                        }
                    } ?? []
                    print("Total users found: \(users.count)")
                    completion(users)
                }
            }
    }
    
    func toggleFollow(for user: AppUser, currentUserID: String, completion: @escaping (Bool) -> Void) {
        let followingRef = db.collection("users").document(currentUserID).collection("following").document(user.id)
        
        followingRef.getDocument { (document, error) in
            if let document = document, document.exists {
                // Unfollow
                followingRef.delete { error in
                    if let error = error {
                        print("Error unfollowing user: \(error)")
                        completion(false)
                    } else {
                        completion(true) // Return false for unfollowed
                    }
                }
            } else {
                // Follow
                followingRef.setData([:]) { error in
                    if let error = error {
                        print("Error following user: \(error)")
                        completion(false)
                    } else {
                        completion(true) // Return true for followed
                    }
                }
            }
        }
    }
    
    func isFollowing(currentUserID: String, otherUserID: String, completion: @escaping (Bool) -> Void) {
        db.collection("users").document(currentUserID).collection("following").document(otherUserID).getDocument { (document, error) in
            if let document = document, document.exists {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func getFollowingCount(for userID: String, completion: @escaping (Int) -> Void) {
        db.collection("users").document(userID).collection("following").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting following count: \(error.localizedDescription)")
                completion(0)
            } else {
                let count = querySnapshot?.documents.count ?? 0
                completion(count)
            }
        }
    }

    func getFollowerCount(for userID: String, completion: @escaping (Int) -> Void) {
        db.collection("users").whereField("following", arrayContains: userID).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting follower count: \(error.localizedDescription)")
                completion(0)
            } else {
                let count = querySnapshot?.documents.count ?? 0
                completion(count)
            }
        }
    }
    
    func savePostcard(for userID: String, postcard: Postcard, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let postcardRef = db.collection("users").document(userID).collection("postcards").document()
            try postcardRef.setData(from: postcard) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
}
