//
//  Category.swift
//  App
//
//  Created by Lukas Hrebik on 09/09/2018.
//

import Foundation
import Vapor
import FluentPostgreSQL

final class Category: Codable {
    var id: Int?
    var name: String
    
    init(name: String) {
        self.name = name
    }
}
