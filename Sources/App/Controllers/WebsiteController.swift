import Vapor
import Leaf
import Fluent
import Authentication
import Foundation

struct WebsiteController: RouteCollection {
    func boot(router: Router) throws {
        let authSessionRoute = router.grouped(User.authSessionsMiddleware())
        
        authSessionRoute.get(use: indexHandler)
        authSessionRoute.get("cenik", use: cenikHandler)
        authSessionRoute.get("contact", use: contactHandler)
        authSessionRoute.get("payments", use: payments)
        authSessionRoute.get("elektroodpad-cenik", use: elektroodpady)
        
        //English translate
        authSessionRoute.get("eng/engindex", use: engIndexHadnler)
        authSessionRoute.get("eng/engcontact", use: engcontactHandler)
        authSessionRoute.get("eng/engpricelist", use: engcenikHandler)

        authSessionRoute.get("login", use: loginHandler)
        authSessionRoute.post(LoginPostData.self, at: "login", use: loginPostHandler)
        authSessionRoute.post("logout", use: logoutHandler)
        
        authSessionRoute.post(Materials.self, at: "create-materials", use: createMaterialPostHandler)
        authSessionRoute.post(ComponentsMaterial.self, at: "create-elektro-material", use: createElektroPostHandler)
        
        let protectedRoutes = authSessionRoute.grouped(RedirectMiddleware<User>(path: "/login"))
        protectedRoutes.get("create-materials", use: createMaterialHandler)
        protectedRoutes.get("create-elektro-material", use: createElektroComponentHandler)
        protectedRoutes.get("material", Materials.parameter, "edit", use: editMaterialHandler)
        protectedRoutes.post("material", Materials.parameter, "edit", use: editMaterialPostHandler)
        protectedRoutes.post("materials", Materials.parameter, "delete", use: deleteMaterialHandler)
        
        protectedRoutes.post("elektro", ComponentsMaterial.parameter, "delete", use: deleteElektroHandler)
        protectedRoutes.get("elektro", ComponentsMaterial.parameter, "edit", use: editElektroHandler)
        protectedRoutes.post("elektro", ComponentsMaterial.parameter, "edit", use: editElektroPostHandler)


    }
    
    //MARK: English
    func engIndexHadnler(_ req: Request) throws -> Future<View> {
        return Materials.query(on: req).filter(\.mainpage == "1").all().flatMap(to: View.self) { result in
            let result = result.isEmpty ? nil : result
            let userLoggedIn = try req.isAuthenticated(User.self)
            let context = IndexContent(title: "Homepage",
                                       mainpageMaterials: result,
                                       userLoggedIn: userLoggedIn)
            return try req.view().render("engindex", context)
        }
    }
    
    func engcontactHandler(_ req: Request) throws -> Future<View> {
        let userLoggedIn = try req.isAuthenticated(User.self)
        let context = ContactContent(title: "Contact", userLoggedIn: userLoggedIn)
        return try req.view().render("engcontact", context)
    }
    
    func engcenikHandler(_ req: Request) throws -> Future<View> {
        let bitcoinURL = "https://min-api.cryptocompare.com/data/price?fsym=BTC&tsyms=CZK"
        
        return try req.client().get(bitcoinURL).flatMap(to: View.self) { resp in
            let btc = try resp.content.syncDecode(Bitcoin.self)
        
            //return try req.view().render("cenik")
            return Materials.query(on: req)
                .sort(\.title, .ascending)
                .all().flatMap(to: View.self) { cenik in
                    let materialData = cenik.isEmpty ? nil : cenik
                    let userLoggedIn = try req.isAuthenticated(User.self)
                    let context = CenikContent(title: "Price List", cenik: materialData,
                                               userLoggedIn: userLoggedIn, bitcoin: btc)
                    
                    return try req.view().render("engpricelist", context)
            }
        }
    }
    
    func indexHandler(_ req: Request) throws -> Future<View> {
        return Materials.query(on: req).filter(\.mainpage == "1").all().flatMap(to: View.self) { result in
            let result = result.isEmpty ? nil : result
            let userLoggedIn = try req.isAuthenticated(User.self)
            let context = IndexContent(title: "Homepage",
                                    mainpageMaterials: result,
                                    userLoggedIn: userLoggedIn)
            return try req.view().render("index", context)
        }
    }
    
    func contactHandler(_ req: Request) throws -> Future<View> {
        let userLoggedIn = try req.isAuthenticated(User.self)
        let context = ContactContent(title: "Kontakt", userLoggedIn: userLoggedIn)
        return try req.view().render("contact", context)
    }

    func cenikHandler(_ req: Request) throws -> Future<View> {
    
        let bitcoinURL = "https://min-api.cryptocompare.com/data/price?fsym=BTC&tsyms=CZK"
        
        return try req.client().get(bitcoinURL).flatMap(to: View.self) { resp in
            let btc = try resp.content.syncDecode(Bitcoin.self)
        
            
            //return try req.view().render("cenik")
            return Materials.query(on: req)
                .sort(\.title, .ascending)
                .all().flatMap(to: View.self) { cenik in
                    let materialData = cenik.isEmpty ? nil : cenik
                    let userLoggedIn = try req.isAuthenticated(User.self)
                    let context = CenikContent(title: "Ceník", cenik: materialData,
                                               userLoggedIn: userLoggedIn, bitcoin: btc)
                    
                    return try req.view().render("cenik", context)
                    
            }

        }
    
//        return try req.client().get(bitcoinURL).flatMap(to: View.self) { request in
//            let context = try request.content.syncDecode(View.self)
//            return try req.view().render("cenik", context)
//        }
        
        /*
        return Materials.query(on: req)
            .sort(\.title, .ascending)
            .all().flatMap(to: View.self) { cenik in
                let materialData = cenik.isEmpty ? nil : cenik
                let userLoggedIn = try req.isAuthenticated(User.self)
                let context = CenikContent(title: "Ceník", cenik: materialData,
                                           userLoggedIn: userLoggedIn)
                
            return try req.view().render("cenik", context)
            
        }
 */
    }

    func payments(_ req: Request) throws -> Future<View> {
        return try req.view().render("payments")
    }
    
    func loginHandler(_ req: Request) throws -> Future<View> {
        let context = LoginContext()
        return try req.view().render("login", context)
    }
    
    func loginPostHandler(_ req: Request, userData: LoginPostData) throws -> Future<Response> {
        return User.authenticate(username: userData.username,
                                 password: userData.password,
                                 using: BCryptDigest(), on: req)
            .map(to: Response.self) { user in
                guard let user = user else {
                    return req.redirect(to: "/login")
                }
                
                try req.authenticateSession(user)
                return req.redirect(to: "/")
        }
    }
    
    func logoutHandler(_ req: Request) throws -> Response {
        try req.unauthenticateSession(User.self)
        return req.redirect(to: "/")
    }
    
    func elektroodpady(_ req: Request) throws -> Future<View> {
        return ComponentsMaterial.query(on: req)
            .sort(\.title, .ascending)
            .all().flatMap(to: View.self) { cenik in
                let materialData = cenik.isEmpty ? nil : cenik
                let userLoggedIn = try req.isAuthenticated(User.self)
                let context = ElektroCenikContant(title: "Ceník Elektroodpad", cenik: materialData,
                                                  userLoggedIn: userLoggedIn)
                
                return try req.view().render("elektroodpad-cenik", context)
        }
    }
    
    func createElektroComponentHandler(_ req: Request) throws -> Future<View> {
        let userLoggedIn = try req.isAuthenticated(User.self)
        return try req.view().render("create-elektro-material", userLoggedIn)
    }
    
    func createElektroPostHandler(_ req: Request, data: ComponentsMaterial) throws -> Future<Response> {
        return data.save(on: req).map(to: Response.self)  { elektro in
            return req.redirect(to: "/elektroodpad-cenik")
        }
    }
    
    func deleteElektroHandler(_ req: Request) throws -> Future<Response> {
        return try req.parameters.next(ComponentsMaterial.self).delete(on: req)
            .transform(to: req.redirect(to: "/elektroodpad-cenik"))
    }
    
    func editElektroHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(ComponentsMaterial.self).flatMap(to: View.self) { material in
            let context = EditElektroContext(material: material)
            return try req.view().render("create-elektro-material", context)
        }
    }
    
    func editElektroPostHandler(_ req: Request) throws -> Future<Response> {
        return try flatMap(to: Response.self, req.parameters.next(ComponentsMaterial.self),
                           req.content.decode(CreateElektroData.self)) { material, data in
                            material.title = data.title
                            material.desc = data.desc
                            material.code = data.code
                            material.priceKg = data.priceKg
                            material.priceQt = data.priceQt
                            material.imageUrl = data.imageUrl
                            material.type = data.type
                            
                            return material.save(on: req).map(to: Response.self) { savedMaterial in
                                guard let id = savedMaterial.id else {
                                    throw Abort(.internalServerError)
                                }
                                
                                return req.redirect(to: "/elektroodpad-cenik")
                            }
        }
    }
    
    func createMaterialHandler(_ req: Request) throws -> Future<View> {
        let userLoggedIn = try req.isAuthenticated(User.self)
        return try req.view().render("createMaterials", userLoggedIn)
    }
    
    func createMaterialPostHandler(_ req: Request, data: Materials) throws -> Future<Response> {
        return data.save(on: req).map(to: Response.self) { mat in
            
            return req.redirect(to: "/cenik")
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
                            material.code = data.code
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
    let mainpageMaterials: [Materials]?
    let userLoggedIn: Bool
}

struct CenikContent: Encodable {
    let title: String
    let cenik: [Materials]?
    let userLoggedIn: Bool
    let bitcoin: Bitcoin
}

struct ElektroCenikContant: Encodable {
    let title: String
    let cenik: [ComponentsMaterial]?
    let userLoggedIn: Bool
}

struct ContactContent: Encodable {
    let title: String
    let userLoggedIn: Bool
}

struct LoginContext: Encodable {
    let title: String = "Log In"
}

struct LoginPostData: Content {
    let username: String
    let password: String
}

struct CreateElektroData: Content {
    let title: String
    let desc: String
    let priceKg: String
    let priceQt: String
    let type: String
    let code: String
    let imageUrl: String
}

struct EditElektroContext: Encodable {
    let title = "Edit Elektro"
    let material: ComponentsMaterial
    let editing = true
}

struct CreateMaterialsData: Content {
    let title: String
    let desc: String
    let price: String
    let mainpage: String
    let type: String
    let code: String
}

struct EditMaterialContext: Encodable {
    let title = "Edit Material"
    let material: Materials
    let editing = true
}

struct Bitcoin: Content {
    let CZK: Double
}

