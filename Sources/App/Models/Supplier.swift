import Vapor
import FluentPostgreSQL

final class Supplier: Codable {
    var id: Int?
    var fullName: String
    var adressStreet: String
    var adressCity: String
    var phone: String?
    var id1: String
    var id2: String
    var bankAccount: String?
    
    init(fullName: String, adressStreet: String, adressCity: String, phone: String, id1: String, id2: String, bankAccount: String) {
        self.fullName = fullName
        self.adressStreet = adressStreet
        self.adressCity = adressCity
        self.phone = phone
        self.id1 = id1
        self.id2 = id2
    }
    
}

extension Supplier: PostgreSQLModel {}
extension Supplier: Content {}
extension Supplier: Parameter {}
extension Supplier: Migration {}
