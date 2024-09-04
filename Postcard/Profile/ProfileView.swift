//
//  ProfileView.swift
//  Postcard
//
//  Created by Anna Hull on 8/2/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

// MARK: - Profile View
struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                        
                        VStack(alignment: .leading) {
                            Text(viewModel.user?.username ?? "Username")
                                .font(.title)
                            Text("Postcards: \(viewModel.user?.postcards?.count ?? 0)")
                            Text("Following: \(viewModel.followingCount)")
                            Text("Followers: \(viewModel.followerCount)")
                        }
                    }
                    .padding()
                    
                    Text("My Collection")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) {
                        ForEach(viewModel.user?.postcards ?? []) { postcard in
                            PostcardThumbnailView(postcard: postcard)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                NavigationLink("Edit", destination: SettingsView())
            }
        }
        .onAppear {
            viewModel.fetchUserData()
        }
    }
}

class ProfileViewModel: ObservableObject {
    @Published var user: AppUser?
    @Published var followingCount = 0
    @Published var followerCount = 0
    
    private var db = Firestore.firestore()
    private let userService = UserService()
    
    func fetchUserData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let userRef = db.collection("users").document(userId)
        
        userRef.getDocument { [weak self] (document, error) in
            guard let document = document, document.exists else {
                print("Error fetching user document: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                self?.user = try document.data(as: AppUser.self)
                self?.fetchCounts(for: userId)
            } catch {
                print("Error decoding user: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchCounts(for userID: String) {
        userService.getFollowingCount(for: userID) { [weak self] count in
            DispatchQueue.main.async {
                self?.followingCount = count
            }
        }
        
        userService.getFollowerCount(for: userID) { [weak self] count in
            DispatchQueue.main.async {
                self?.followerCount = count
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
