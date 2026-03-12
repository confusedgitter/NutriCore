//
//  FoodItem.swift
//  NutriCore
//
//  Created by Mukunth Parthasarathy on 02/03/2026.
//

import Foundation

enum ItemStatus: String, Codable {
    case active
    case consumed
    case wasted
}

struct FoodItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var quantity: Int
    var expiryDate: Date
    var status: ItemStatus
    var completedDate: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case quantity
        case expiryDate
        case status
        case completedDate
    }
    
    init(id: UUID,
         name: String,
         quantity: Int,
         expiryDate: Date,
         status: ItemStatus = .active,
         completedDate: Date? = nil) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.expiryDate = expiryDate
        self.status = status
        self.completedDate = completedDate
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        quantity = try container.decode(Int.self, forKey: .quantity)
        expiryDate = try container.decode(Date.self, forKey: .expiryDate)
        
        status = try container.decodeIfPresent(ItemStatus.self, forKey: .status) ?? .active
        completedDate = try container.decodeIfPresent(Date.self, forKey: .completedDate)
    }
}
