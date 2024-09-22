//
//  SocialFeedView.swift
//  Postcard
//
//  Created by Anna Hull on 8/2/24.
//

import SwiftUI
import MapKit

// MARK: - Social Feed View
struct SocialFeedView: View {
    @State private var friendsPostcards: [Postcard] = []
    
    var body: some View {
        NavigationView {
            List {
                ForEach(friendsPostcards) { postcard in
                    SocialPostcardView(postcard: postcard)
                }
            }
            .navigationTitle("Social Feed")
            .onAppear {
                loadFriendsPostcards()
            }
        }
    }
    
    func loadFriendsPostcards() {
        // Here you would typically load postcards from an API or Firestore
        // For now, we'll use sample data
        friendsPostcards = [
            Postcard(id: "1", imageUrl: "https://etias.com/assets/uploads/8%20Things%20To%20Do%20in%20Paris,%20France.jpg", location: "Paris", dateScanned: Date(), coordinate: Coordinate(latitude: 48.8566, longitude: 2.3522)),
            Postcard(id: "2", imageUrl: "https://example.com/newyork.jpg", location: "New York", dateScanned: Date(), coordinate: Coordinate(latitude: 40.7128, longitude: -74.0060)),
            Postcard(id: "3", imageUrl: "https://example.com/tokyo.jpg", location: "Tokyo", dateScanned: Date(), coordinate: Coordinate(latitude: 35.6762, longitude: 139.6503))
        ]
    }
}

struct SocialPostcardView: View {
    let postcard: Postcard
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(postcard.location)
                .font(.headline)
            
            AsyncImage(url: URL(string: postcard.imageUrl)) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Color.gray
            }
            .frame(height: 200)
            
            Text("Collected on \(postcard.dateScanned, style: .date)")
                .font(.caption)
            
            Text("Coordinates: \(postcard.coordinate.latitude), \(postcard.coordinate.longitude)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    SocialFeedView()
}
