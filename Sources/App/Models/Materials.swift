import Vapor
import FluentPostgreSQL

final class Materials: Codable {
    var id: Int?
    var title: String
    var code: String
    var desc: String
    var price: String
    
    init(title: String, desc: String, price: String, code: String) {
        self.title = title
        self.desc = desc
        self.price = price
        self.code = code
    }
}

extension Materials: PostgreSQLModel {}
extension Materials: Content {}
extension Materials: Parameter {}
extension Materials: Migration {}
