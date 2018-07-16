import Vapor
import FluentPostgreSQL

final class Materials: Codable {
    var id: Int?
    var title: String
    var code: String
    var desc: String
    var price: String
    var type: String
    var mainpage: String
    
    init(title: String, desc: String, price: String, code: String, type: String, mainpage: String) {
        self.title = title
        self.desc = desc
        self.price = price
        self.code = code
        self.type = type
        self.mainpage = mainpage
    }
}

extension Materials: PostgreSQLModel {}
extension Materials: Content {}
extension Materials: Parameter {}
extension Materials: Migration {}
