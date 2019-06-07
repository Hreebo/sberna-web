//
//  ComponentsMaterial.swift
//  App
//
//  Created by Lukas Hrebik on 06/06/2019.
//

import Vapor
import FluentPostgreSQL

final class ComponentsMaterial: Codable {
    var id: Int?
    var title: String
    var code: String
    var desc: String
    var type: String
    var imageUrl: String
    var priceKg: String
    var priceQt: String
    
    init(title: String, code: String, desc: String, type: String, imageUrl: String, priceKg: String, priceQt: String) {
        self.title = title
        self.code = code
        self.desc = desc
        self.type = type
        self.imageUrl = imageUrl
        self.priceKg = priceKg
        self.priceQt = priceQt
    }
}

extension ComponentsMaterial: PostgreSQLModel {}
extension ComponentsMaterial: Content {}
extension ComponentsMaterial: Parameter {}
extension ComponentsMaterial: Migration {}
