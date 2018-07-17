import Vapor
import Fluent

struct MaterialsController: RouteCollection {
   
    func boot(router: Router) throws {
        let materialsRoutes = router.grouped("api", "materials")
        materialsRoutes.get(use: getAllMaterials)
        materialsRoutes.get(Materials.parameter, use: getHandler)
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
}


