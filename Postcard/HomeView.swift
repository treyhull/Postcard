import SwiftUI
import MapKit

// MARK: - Home View
struct HomeView: View {
    @State private var recentPostcards: [Postcard] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Welcome back, User!")
                        .font(.title)
                        .padding(.horizontal)
                    
                    Text("Recent Postcards")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(recentPostcards) { postcard in
                                PostcardThumbnailView(postcard: postcard)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Text("Nearby Locations")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    // Add a list or grid of nearby locations here
                }
            }
            .navigationTitle("Home")
            .onAppear {
                loadRecentPostcards()
            }
        }
    }
    
    func loadRecentPostcards() {
    }
}

#Preview {
    HomeView()
}
