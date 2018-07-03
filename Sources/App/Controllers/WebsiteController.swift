import Vapor
import Leaf
import Fluent
import Authentication

struct WebsiteController: RouteCollection {
    func boot(router: Router) throws {
        router.get(use: indexHandler)
    }
    
    func indexHandler(_ req: Request) throws -> Future<View> {
        let context = IndexContent(title: "Homegape")
        return try req.view().render("index", context)
    }
 }

struct IndexContent: Encodable {
    let title: String
}
