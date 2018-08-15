//
//  AddMaterial.swift
//  App
//
//  Created by Lukas Hrebik on 15/08/2018.
//

import Foundation
import FluentPostgreSQL
import Vapor

struct AddMaterialToMateril: Migration {

    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return Database.update(Materials.self, on: conn, closure: { (builder) in
            builder.field(for: \.oldPrice)
        })
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return Database.update(Materials.self, on: conn, closure: { (builder) in
            builder.deleteField(for: \.oldPrice)
        })
    }
}


