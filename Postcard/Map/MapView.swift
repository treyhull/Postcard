//
//  MapView.swift
//  Postcard
//
//  Created by Anna Hull on 8/2/24.
//

import SwiftUI
import MapKit

// MARK: - Map View

struct MapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var selectedLocation: Location?
    
    var locations: [Location] = [] // Populate this with collected postcards
    
    var body: some View {
        Map(coordinateRegion: $region, annotationItems: locations) { location in
            MapAnnotation(coordinate: location.coordinate) {
                Image(systemName: "mappin")
                    .foregroundColor(.red)
                    .onTapGesture {
                        selectedLocation = location
                    }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .sheet(item: $selectedLocation) { location in
            LocationDetailView(location: location)
        }
    }
}

struct LocationDetailView: View {
    let location: Location
    
    var body: some View {
        VStack {
            Text(location.name)
                .font(.title)
            
            // Add more details about the location here
            // Such as the postcard image, date collected, etc.
        }
    }
}

#Preview {
    MapView()
}
