import Foundation

struct ShoppingItem: Identifiable, Codable {
    var id = UUID()
    var name: String
    var isPurchased: Bool = false
}
