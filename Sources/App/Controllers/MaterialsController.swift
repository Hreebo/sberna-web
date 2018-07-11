import Vapor
import Fluent

struct MaterialsController: RouteCollection {
   
    func boot(router: Router) throws {
        let materialsRoutes = router.grouped("api", "materials")
        materialsRoutes.get(use: getAllMaterials)
    }
    
    func getAllMaterials(_ req: Request) throws -> Future<[Materials]> {
        return Materials.query(on: req).all()
    }
}


