import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    let websiteController = WebsiteController()
    try router.register(collection: websiteController)
    
    let materialsController = MaterialsController()
    try router.register(collection: materialsController)
    
    let userController = UserController()
    try router.register(collection: userController)
    
}
