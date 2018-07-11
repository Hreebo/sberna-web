import Vapor
import Leaf
import Fluent
import Authentication
import Foundation

struct WebsiteController: RouteCollection {
    func boot(router: Router) throws {
        router.get(use: indexHandler)
        router.get("cenik", use: cenikHandler)
        router.get("login", use: loginHandler)
        router.get("createMaterials", use: createMaterialHandler)
        
        router.post(Materials.self, at: "createMaterials", use: createMaterialPostHandler)
    }
    
    func indexHandler(_ req: Request) throws -> Future<View> {
      
        let hour = Date()
        let time = hour.getTodayString()
        
        let context = IndexContent(title: "Homepage", text: "Toto je tesovaci page.", time: "\(time)", isOpen: false)
        return try req.view().render("index", context)
    }
    
    func cenikHandler(_ req: Request) throws -> Future<View> {
        return Materials.query(on: req)
            .sort(\.title, .ascending)
            .all().flatMap(to: View.self) { cenik in
            let materialData = cenik.isEmpty ? nil : cenik
            let context = CenikContent(title: "Cenik", cenik: materialData)
            return try req.view().render("cenik", context)
        }
    }
    
    func loginHandler(_ req: Request) throws -> Future<View> {
        let context = LoginContext()
        return try req.view().render("login", context)
    }
    
    func loginPostHandler(_ req: Request, userData: LoginPostData) throws -> Future<View> {
        return try req.view().render("/")
    }
    
    func createMaterialHandler(_ req: Request) throws -> Future<View> {
        return try req.view().render("createMaterials")
    }
    
    func createMaterialPostHandler(_ req: Request, data: Materials) throws -> Future<Response> {
        return data.save(on: req).map(to: Response.self) { mat in
            guard let id = data.id else {
                throw Abort(.internalServerError)
            }
            return req.redirect(to: "/")
        }
    }
 }

struct IndexContent: Encodable {
    let title: String
    let text: String
    let time: String
    let isOpen: Bool?
}

struct CenikContent: Encodable {
    let title: String
    let cenik: [Materials]?
}

struct LoginContext: Encodable {
    let title: String = "Log In"
}

struct LoginPostData: Content {
    let username: String
    let password: String
}

struct CreateMaterialsData {
    let name: String
    let desc: String
    
}
