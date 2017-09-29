//
//  Event.swift
//  nearby-api
//
//  Created by Andre Rosa on 12/09/17.
//
//

import StORM
import PostgresStORM

class Event: PostgresStORM {
    
    var id          : Int       = 0
    var name        : String    = ""
    var description : String    = ""
    var eventType   : String    = ""
    var location    : String    = ""
    var eventDate   : String    = ""
    var criator     : Int       = 0
    
    
    override open func table() -> String { return "events" }
    
    override func to(_ this: StORMRow){
        id              = this.data["id"]           as? Int     ?? 0
        name            = this.data["name"]         as? String  ?? ""
        description     = this.data["description"]  as? String  ?? ""
        eventType       = this.data["eventtype"]    as? String  ?? ""
        location        = this.data["location"]     as? String  ?? ""
        eventDate       = this.data["eventdate"]    as? String  ?? ""
        criator         = this.data["criator"]      as? Int     ?? 0
        
    }
    func rows() -> [Event] {
        var rows = [Event]()
        for i in 0..<self.results.rows.count {
            let row = Event()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    func asDictionary() -> [String: Any]{
        
        return [
            "id"            : self.id,
            "name"          : self.name,
            "description"   : self.description,
            "eventType"     : self.eventType,
            "location"      : self.location,
            "eventDate"     : self.eventDate,
            "criator"       : self.criator
        ]
    }
}
