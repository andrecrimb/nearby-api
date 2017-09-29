//
//  EventPartic.swift
//  nearby-api
//
//  Created by Andre Rosa on 13/09/17.
//
//


import StORM
import PostgresStORM

class EventPartic: PostgresStORM {
    
    var id          : Int = 0
    var idevent    : Int = 0
    var uuid        : Int = 0
    
    override open func table() -> String { return "event_partic" }
    
    override func to(_ this: StORMRow){
        id          = this.data["id"] as? Int ?? 0
        idevent    = this.data["idevent"] as? Int ?? 0
        uuid        = this.data["uuid"] as? Int ?? 0
    }
    func rows() -> [EventPartic] {
        var rows = [EventPartic]()
        for i in 0..<self.results.rows.count {
            let row = EventPartic()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    func asDictionary() -> [String: Any]{
        return [
            "id"        : self.id,
            "idEvent"  : self.idevent,
            "uuid"      : self.uuid,
        ]
    }
}
