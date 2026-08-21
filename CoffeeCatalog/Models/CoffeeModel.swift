//
//  CoffeeModel.swift
//  CoffeeCatalog
//
//  Created by Christina Stadnytska on 07.07.2026.
//

import Foundation

enum CoffeeCategory: String {
    case hot, iced
}

struct CoffeeModel: Identifiable, Hashable, Codable {
    let id: UUID
    let serverId: Int?
    let title: String
    let description: String?
    let ingredients: [String]?
    let image: String?
    
    var favourite: Bool = false
    
    init(id: UUID = UUID(),
         serverId: Int? = nil,
         title: String,
         description: String? = nil,
         ingredients: [String]? = nil,
         image: String? = nil,
         favourite: Bool = false
    ) {
        self.id = id
        self.serverId = serverId
        self.title = title
        self.description = description
        self.ingredients = ingredients
        self.image = image
        self.favourite = favourite
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, ingredients, image
    }
    
    init(from decoder: any Decoder) throws {
        let cModel = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.serverId = try cModel.decodeIfPresent(Int.self, forKey: .id)
        self.title = try cModel.decode(String.self, forKey: .title)
        self.description = try cModel.decodeIfPresent(String.self, forKey: .description)
        if let ingredientsArray = try? cModel.decodeIfPresent([String].self, forKey: .ingredients) {
            self.ingredients = ingredientsArray
        } else if let ingredient = try? cModel.decodeIfPresent(String.self, forKey: .ingredients) {
            self.ingredients = [ingredient]
        } else {
            self.ingredients = nil
        }
        self.image = try cModel.decodeIfPresent(String.self, forKey: .image)
        self.favourite = false
    }
}
