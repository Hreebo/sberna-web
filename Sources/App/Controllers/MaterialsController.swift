import Vapor
import Fluent

struct MaterialsController: RouteCollection {
   
    func boot(router: Router) throws {
        let materialsRoutes = router.grouped("api", "materials")
        materialsRoutes.get(use: getAllMaterials)
        materialsRoutes.get(Materials.parameter, use: getHandler)
        materialsRoutes.get("search", use: searchHandler)
        materialsRoutes.get("sorted", use: sortedHandler)
        materialsRoutes.delete("del", use: deleteHandler)

        materialsRoutes.get("elektro", use: getAllElektro)
        
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddlerware = User.guardAuthMiddleware()
        let tokenAuthGroup = materialsRoutes.grouped(tokenAuthMiddleware, guardAuthMiddlerware)
        tokenAuthGroup.post(MaterialCreateData.self, use: createHandler)
        tokenAuthGroup.delete(Materials.parameter, use: deleteHandler)
        tokenAuthGroup.put(Materials.parameter, use: updateHandler)
    }
    
    
    func getAllElektro(_ req: Request) throws -> Future<[ComponentsMaterial]> {
        return ComponentsMaterial.query(on: req).all()
    }
    
    func getAllMaterials(_ req: Request) throws -> Future<[Materials]> {
        return Materials.query(on: req).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<Materials> {
        return try req.parameters.next(Materials.self)
    }
    
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Materials.self).delete(on: req).transform(to: HTTPStatus.noContent)
    }
    
    func sortedHandler(_ req: Request) throws -> Future<[Materials]> {
        return Materials.query(on: req).sort(\.title, .ascending).all()
    }
    
    func searchHandler(_ req: Request) throws -> Future<[Materials]> {
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        return Materials.query(on: req).group(.or) { or in
            or.filter(\.title == searchTerm)
            }.all()
    }
    
    func createHandler(_ req: Request, data: MaterialCreateData) throws -> Future<Materials> {
        let material = Materials(title: data.title, desc: data.desc, price: data.price, code: data.code, type: data.type, mainpage: data.mainpage)
        return material.save(on: req)
    }
    
    func updateHandler(_ req: Request) throws -> Future<Materials> {
        return try flatMap(to: Materials.self,
                           req.parameters.next(Materials.self),
                           req.content.decode(MaterialCreateData.self)) { material, updateData in
                            material.title = updateData.title
                            material.code = updateData.code
                            material.price = updateData.price
                            material.type = updateData.type
                            material.mainpage = updateData.mainpage
                            
                            return material.save(on: req)
        }
    }
}

struct MaterialCreateData: Content {
    let title: String
    let desc: String
    let price: String
    let code: String
    let type: String
    let mainpage: String
}

