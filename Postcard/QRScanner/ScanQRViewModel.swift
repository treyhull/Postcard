import SwiftUI
import AVFoundation
import CoreLocation
import FirebaseAuth

class ScanQRViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var scannedCode: String?
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var postcards: [Postcard] = []
    
    private let userService = UserService()
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        // Fetch postcards from a URL or a different source if needed
    }
    
    func handleScannedCode(_ code: String) {
        self.scannedCode = code
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let coordinate = Coordinate(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        // Here, you would typically parse the QR code to extract postcard information
        // For this example, we'll use the scanned code as the imageUrl
        let postcard = Postcard(imageUrl: scannedCode ?? "https://example.com/default.jpg",
                                location: "Current Location", // You might want to reverse geocode this
                                dateScanned: Date(),
                                coordinate: coordinate)
        
        guard let userID = Auth.auth().currentUser?.uid else {
            self.showAlert = true
            self.alertMessage = "User not logged in"
            return
        }
        
        userService.savePostcard(for: userID, postcard: postcard) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.showAlert = true
                    self.alertMessage = "Postcard saved successfully!"
                case .failure(let error):
                    self.showAlert = true
                    self.alertMessage = "Failed to save postcard: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
        self.showAlert = true
        self.alertMessage = "Failed to get location: \(error.localizedDescription)"
    }
    
    // Convert JSON string to Postcard objects
    func decodePostcards(from jsonString: String) {
        guard let data = jsonString.data(using: .utf8) else {
            print("Failed to convert JSON string to Data")
            return
        }
        
        do {
            // Decode the JSON data into an array of Postcard objects
            let decoder = JSONDecoder()
            // Configure the date decoding strategy
            decoder.dateDecodingStrategy = .iso8601
            self.postcards = try decoder.decode([Postcard].self, from: data)
            DispatchQueue.main.async {
                // Notify the UI on the main thread
                print("Postcards successfully decoded from JSON string")
            }
        } catch {
            print("Failed to decode JSON: \(error.localizedDescription)")
        }
    }
}
