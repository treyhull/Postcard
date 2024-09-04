import SwiftUI
import MapKit

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        
        Group {
            if authViewModel.isAuthenticated {
                TabView {
                    SocialFeedView()
                        .tabItem {
                            Label("Social", systemImage: "person.3")
                        }
                    
                    SearchView()
                        .tabItem {
                            Label("Search", systemImage: "magnifyingglass")
                        }
                    
                    NearbyPostcardsMapView()
                        .tabItem {
                            Label("Collect", systemImage: "map")
                        }
                    
                    NotificationFeedView()
                        .tabItem {
                            Label("Notifications", systemImage: "bell")
                        }
                    
                    ProfileView()
                        .tabItem {
                            Label("Profile", systemImage: "person")
                        }
                }
            } else {
                LoginView()
            }
        }
    }
}
