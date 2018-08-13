//
//  UserController.swift
//  App
//
//  Created by Lukas Hrebik on 17/07/2018.
//

import Foundation
import Vapor
import Fluent
import Authentication

struct  UserController: RouteCollection {
    
    func boot(router: Router) throws {
        let userRoute = router.grouped("api", "users")
        
        userRoute.get(use: getAllHandler)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[User.Public]> {
        return User.query(on: req).decode(data: User.Public.self).all()
    }

    func loginHandler(_ req: Request) throws -> Future<Token> {
        let user = try req.requireAuthenticated(User.self)
        let token = try Token.generate(for: user)
        return token.save(on: req)
    }
}
