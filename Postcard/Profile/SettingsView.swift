//
//  SettingsView.swift
//  Postcard
//
//  Created by Anna Hull on 8/24/24.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Profile Content")
                
                Button("Sign Out") {
                    authViewModel.signOut()
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    SettingsView()
}
