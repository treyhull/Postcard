import SwiftUI
import MapKit

struct NearbyPostcardsMapView: View {
    @StateObject private var viewModel = NearbyPostcardsViewModel()
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: Binding(
                get: { self.viewModel.region },
                set: { self.viewModel.updateRegion($0) }
            ), showsUserLocation: true, annotationItems: viewModel.nearbyPostcards) { postcard in
                MapAnnotation(coordinate: postcard.clCoordinate) {
                    PostcardAnnotationView(postcard: postcard)
                }
            }
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                if let error = viewModel.locationError {
                    Text(error)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(10)
                        .padding(.bottom)
                }
                Text("Nearby Postcards: \(viewModel.nearbyPostcards.count)")
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                    .padding(.bottom)
            }
        }
        .onAppear {
            viewModel.startLocationUpdates()
        }
    }
}

struct PostcardAnnotationView: View {
    let postcard: Postcard
    
    var body: some View {
        VStack {
            Image(systemName: "mail.fill")
                .foregroundColor(.red)
                .font(.title)
            Text(postcard.location)
                .font(.caption)
                .background(Color.white.opacity(0.8))
                .cornerRadius(5)
        }
    }
}

class NearbyPostcardsViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @Published var nearbyPostcards: [Postcard] = []
    @Published var locationError: String?
    
    private let locationManager = CLLocationManager()
    private var userLocation: CLLocationCoordinate2D?
    private let maxDistance: CLLocationDistance = 5000 // 5 km
    private let minZoom: CLLocationDegrees = 0.01
    private let maxZoom: CLLocationDegrees = 0.2
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 500 // Update location every 500 meters
        print("Location manager setup complete")
    }
    
    func startLocationUpdates() {
        print("Attempting to start location updates")
        if CLLocationManager.locationServicesEnabled() {
            switch locationManager.authorizationStatus {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .authorizedWhenInUse, .authorizedAlways:
                locationManager.startUpdatingLocation()
                print("Location updates started")
            case .restricted, .denied:
                print("Location services are not authorized")
            @unknown default:
                break
            }
        } else {
            print("Location services are not enabled")
        }
    }
    
    // MARK: - CLLocationManagerDelegate methods
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("Location authorization status changed: \(manager.authorizationStatus.rawValue)")
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
            print("Location updates started after authorization change")
        default:
            break
        }
    }
    
    func updateRegion(_ newRegion: MKCoordinateRegion) {
        var constrainedRegion = newRegion
        
        // Constrain zoom level
        constrainedRegion.span.latitudeDelta = min(max(newRegion.span.latitudeDelta, minZoom), maxZoom)
        constrainedRegion.span.longitudeDelta = min(max(newRegion.span.longitudeDelta, minZoom), maxZoom)
        
        // Constrain panning
        if let userLocation = userLocation {
            let center = CLLocation(latitude: constrainedRegion.center.latitude, longitude: constrainedRegion.center.longitude)
            let userLoc = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
            
            if center.distance(from: userLoc) > maxDistance {
                let bearing = userLoc.bearing(to: center)
                let constrainedCenter = userLoc.coordinate(at: maxDistance, bearing: bearing)
                constrainedRegion.center = constrainedCenter
            }
        }
        
        DispatchQueue.main.async {
            self.region = constrainedRegion
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location.coordinate
        let newRegion = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        updateRegion(newRegion)
        fetchNearbyPostcards(near: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
    
    private func updateRegion(for location: CLLocation) {
        DispatchQueue.main.async {
            self.region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            print("Updated region to: \(self.region.center)")
        }
    }
    
    func fetchNearbyPostcards(near location: CLLocation) {
        print("Fetching nearby postcards for location: \(location)")
        // Generate random postcards (replace with actual API call in production)
        let randomPostcards = (0..<5).map { _ in
            let randomCoordinate = generateRandomNearbyCoordinate(from: location.coordinate)
            return Postcard(
                id: UUID().uuidString,
                imageUrl: "https://example.com/postcard.jpg",
                location: "Nearby Location",
                dateScanned: Date(),
                coordinate: Coordinate(latitude: randomCoordinate.latitude, longitude: randomCoordinate.longitude)
            )
        }
        
        DispatchQueue.main.async {
            self.nearbyPostcards = randomPostcards
            print("Updated nearby postcards. Count: \(self.nearbyPostcards.count)")
        }
    }
    
    private func generateRandomNearbyCoordinate(from coordinate: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let delta = 0.05 // Roughly 5km
        let lat = coordinate.latitude + Double.random(in: -delta...delta)
        let lon = coordinate.longitude + Double.random(in: -delta...delta)
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

extension Postcard {
    var clCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}

// Helper extensions
extension CLLocation {
    func bearing(to destination: CLLocation) -> Double {
        let lat1 = self.coordinate.latitude.radians
        let lon1 = self.coordinate.longitude.radians
        let lat2 = destination.coordinate.latitude.radians
        let lon2 = destination.coordinate.longitude.radians
        
        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        
        return radiansBearing.degrees
    }
    
    func coordinate(at distance: CLLocationDistance, bearing: Double) -> CLLocationCoordinate2D {
        let distanceRadians = distance / 6371000.0 // Earth radius in meters
        let bearingRadians = bearing.radians
        let lat1 = self.coordinate.latitude.radians
        let lon1 = self.coordinate.longitude.radians
        
        let lat2 = asin(sin(lat1) * cos(distanceRadians) + cos(lat1) * sin(distanceRadians) * cos(bearingRadians))
        let lon2 = lon1 + atan2(sin(bearingRadians) * sin(distanceRadians) * cos(lat1), cos(distanceRadians) - sin(lat1) * sin(lat2))
        
        return CLLocationCoordinate2D(latitude: lat2.degrees, longitude: lon2.degrees)
    }
}

extension Double {
    var radians: Double { return self * .pi / 180 }
    var degrees: Double { return self * 180 / .pi }
}

#Preview {
    NearbyPostcardsMapView()
}
