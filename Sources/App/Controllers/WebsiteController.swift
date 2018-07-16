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
        router.post("materials", Materials.parameter, "delete", use: deleteMaterialHandler)
        router.get("material", Materials.parameter, "edit", use: editMaterialHandler)
        router.post("material", Materials.parameter, "edit", use: editMaterialPostHandler)
        
        router.post(Materials.self, at: "createMaterials", use: createMaterialPostHandler)
    }
    
    func indexHandler(_ req: Request) throws -> Future<View> {
      
        let hour = Date()
        let time = hour.getTodayString()
        
        return Materials.query(on: req).filter(\.mainpage == "1").all().flatMap(to: View.self) { result in
            let result = result.isEmpty ? nil : result
            let context = IndexContent(title: "Homepage", text: "Toto je tesovaci page.",
                                       time: "\(time)", isOpen: false, mainpageMaterials: result)
            return try req.view().render("index", context)
        }
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
    
    func deleteMaterialHandler(_ req: Request) throws -> Future<Response> {
        return try req.parameters.next(Materials.self).delete(on: req)
            .transform(to: req.redirect(to: "/cenik"))
    }
    
    func editMaterialHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(Materials.self).flatMap(to: View.self) { material in
            let context = EditMaterialContext(material: material)
            return try req.view().render("createMaterials", context)
        }
    }
    
    func editMaterialPostHandler(_ req: Request) throws -> Future<Response> {
        return try flatMap(to: Response.self, req.parameters.next(Materials.self),
                           req.content.decode(CreateMaterialsData.self)) { material, data in
                            material.title = data.title
                            material.desc = data.desc
                            material.price = data.price
                            material.mainpage = data.mainpage
                            material.type = data.type
                           
                            return material.save(on: req).map(to: Response.self) { savedMaterial in
                                guard let id = savedMaterial.id else {
                                    throw Abort(.internalServerError)
                                }
                                
                                return req.redirect(to: "/cenik")
                            }
        }
    }
}

struct IndexContent: Encodable {
    let title: String
    let text: String
    let time: String
    let isOpen: Bool?
    let mainpageMaterials: [Materials]?
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

struct CreateMaterialsData: Content {
    let title: String
    let desc: String
    let price: String
    let mainpage: String
    let type: String
}

struct EditMaterialContext: Encodable {
    let title = "Edit Material"
    let material: Materials
    let editing = true
}
