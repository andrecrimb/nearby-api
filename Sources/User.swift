//
//  User.swift
//  nearby-API
//
//  Created by Andre Rosa on 31/08/17.
//
//

import StORM
import PostgresStORM

class User: PostgresStORM {
    
    var id          : Int = 0
    var name        : String = ""
    var email       : String = ""
    var password    : String = ""
    
    
    override open func table() -> String { return "users" }
    
    override func to(_ this: StORMRow) {
        id          = this.data["id"]       as? Int     ?? 0
        name        = this.data["name"]     as? String  ?? ""
        email       = this.data["email"]    as? String  ?? ""
        password    = this.data["password"] as? String  ?? ""
    }
    
    func rows() -> [User] {
        var rows = [User]()
        for i in 0..<self.results.rows.count {
            let row = User()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    func asDictionary() -> [String: Any]{
        return [
            "id"        : self.id,
            "name"      : self.name,
            "email"     : self.email
        ]
    }
    
}
