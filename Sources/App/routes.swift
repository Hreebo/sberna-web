import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    let websiteController = WebsiteController()
    try router.register(collection: websiteController)
    
}
