import SwiftUI
import MapKit
import Firebase
import FirebaseFirestore

// MARK: - Models

struct AppUser: Identifiable, Codable {
    let id: String
    let username: String
    let email: String
    @State var isFollowing: Bool = false
    var following: [String] = []
    var postcards: [Postcard]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case email
    }
}

struct Postcard: Identifiable, Codable {
    @DocumentID var id: String?
    let imageUrl: String
    let location: String
    let dateScanned: Date
    let coordinate: Coordinate
    
    enum CodingKeys: String, CodingKey {
        case id
        case imageUrl
        case location
        case dateScanned
        case coordinate
    }
}

struct Coordinate: Codable {
    let latitude: Double
    let longitude: Double
}

struct Notification: Identifiable {
    let id: String
    let type: NotificationType
    let username: String
    let postcardName: String?
    let timestamp: Date
    
    var message: String {
        switch type {
        case .like:
            return "\(username) liked your \(postcardName ?? "postcard")"
        case .comment:
            return "\(username) commented on your \(postcardName ?? "postcard")"
        case .follow:
            return "\(username) started following you"
        }
    }
}

struct Location: Identifiable {
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D
}

enum NotificationType {
    case like, comment, follow
    
    var iconName: String {
        switch self {
        case .like: return "heart.fill"
        case .comment: return "message.fill"
        case .follow: return "person.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .like: return .red
        case .comment: return .blue
        case .follow: return .green
        }
    }
}

// MARK: - Main App Structure

@main
struct PostcardApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(authViewModel)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        return true
    }
}
