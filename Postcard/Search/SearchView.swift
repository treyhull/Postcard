//
//  SearchView.swift
//  Postcard
//
//  Created by Anna Hull on 8/2/24.
//

import SwiftUI
import MapKit

struct SearchView: View {
    @State private var searchText = ""
    @State private var searchResults: [AppUser] = []
    @StateObject private var userService = UserService()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText, onSearch: performSearch)
                
                List(searchResults) { user in
                    UserRowView(user: user, currentUserID: authViewModel.user?.uid ?? "")
                }
            }
            .navigationTitle("Search Users")
        }
        .onChange(of: searchText) { _ in
            performSearch()
        }
    }
    
    func performSearch() {
        userService.searchUsers(withPrefix: searchText) { users in
            self.searchResults = users.map { user in
                var mutableUser = user
                mutableUser.isFollowing = false // Reset isFollowing
                return mutableUser
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    var onSearch: () -> Void
    
    var body: some View {
        HStack {
            TextField("Search users", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
            
            Button(action: onSearch) {
                Text("Search")
            }
        }
        .padding()
    }
}

struct UserRowView: View {
    @State var user: AppUser
    let currentUserID: String
    @StateObject private var userService = UserService()
    @State private var isFollowing: Bool = false
    
    var body: some View {
        HStack {
            Text(user.username)
            Spacer()
            Button(action: {
                toggleFollow()
            }) {
                Text(isFollowing ? "Unfollow" : "Follow")
            }
            .buttonStyle(BorderedButtonStyle())
        }
        .onAppear {
            checkFollowStatus()
        }
    }
    
    private func checkFollowStatus() {
        userService.isFollowing(currentUserID: currentUserID, otherUserID: user.id) { result in
            isFollowing = result
        }
    }
    
    private func toggleFollow() {
        userService.toggleFollow(for: user, currentUserID: currentUserID) { success in
            if success {
                isFollowing.toggle()
            }
        }
    }
}


#Preview {
    SearchView()
}
