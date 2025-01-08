// Activity.swift

import Foundation

struct Activity: Codable {
    let distance: String       // Example: "5 км"
    let time: String           // Example: "30 минут"
    let type: String           // Example: "Бег"
    let timestamp: String      // Example: "Только что"
    let iconName: String       // Example: "figure.walk.circle"
    let date: Date             // Date and time of the activity
}
