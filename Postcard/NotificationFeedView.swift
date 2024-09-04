//
//  NotificationFeedView.swift
//  Postcard
//
//  Created by Anna Hull on 8/2/24.
//

import SwiftUI

// MARK: - Notification Feed View

struct NotificationFeedView: View {
    @State private var notifications: [Notification] = []
    
    var body: some View {
        NavigationView {
            List(notifications) { notification in
                NotificationRowView(notification: notification)
            }
            .navigationTitle("Notifications")
            .onAppear(perform: loadNotifications)
        }
    }
    
    func loadNotifications() {
        // In a real app, this would fetch notifications from an API
        // For now, we'll use sample data
        notifications = [
            Notification(id: "1", type: .like, username: "john_doe", postcardName: "Paris", timestamp: Date()),
            Notification(id: "2", type: .comment, username: "jane_smith", postcardName: "New York", timestamp: Date().addingTimeInterval(-3600)),
            Notification(id: "3", type: .follow, username: "bob_johnson", postcardName: nil, timestamp: Date().addingTimeInterval(-86400))
        ]
    }
}

struct NotificationRowView: View {
    let notification: Notification
    
    var body: some View {
        HStack {
            Image(systemName: notification.type.iconName)
                .foregroundColor(notification.type.color)
            
            VStack(alignment: .leading) {
                Text(notification.message)
                    .font(.body)
                Text(notification.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    NotificationFeedView()
}
