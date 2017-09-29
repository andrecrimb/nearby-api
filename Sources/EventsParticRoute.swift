//
//  EventsParticRoute.swift
//  nearby-api
//
//  Created by Andre Rosa on 13/09/17.
//
//

import PerfectLib
import PerfectHTTPServer
import PerfectHTTP
import StORM
import PostgresStORM

func EventsParticRoute() -> Routes{
    var routes = Routes()
    
    func addPartic(request: HTTPRequest, response: HTTPResponse){ //working
        
        do{
            let eventPartic = EventPartic()
            
            if let dict = userData as? Dictionary<String,AnyObject>{
                if let userIdJWT = dict["id"]{
                    eventPartic.uuid = userIdJWT as! Int
                }
           
                //verificar
                if let idEvent = request.urlVariables["id"]{
                    
                    try eventPartic.find([("idevent", idEvent),("uuid",eventPartic.uuid)])
                    
                    if eventPartic.id == 0 {
                        
                        try eventPartic.save{ id in eventPartic.id = id as! Int }
                        
                        try response.setBody(json: ["message": "INSERTED"])
                            .setHeader(.contentType, value: "application/json")
                            .completed(status: .created)
                    } else {
                        response.completed(status: .conflict)
                    }
                } else {
                    response.completed(status: .notFound)
                }
            } else{
                response.completed(status: .notFound)
            }
        } catch {
            response.setBody(string: "Error handling request \(error)")
                .completed(status: .internalServerError)
        }
    }
    
    func getParticByIdEvent(request: HTTPRequest, response: HTTPResponse){
        do {
            if let idEvent = request.urlVariables["id"]{
            
                let eventPartic = EventPartic()
                
                try eventPartic.find([("idevent",idEvent)])
                
                var partics: [[String: Any]] = []
                
                for row in eventPartic.rows(){
                    partics.append(row.asDictionary())
                }
                
                try response.setBody(json: partics)
                    .setHeader(.contentType, value: "application/json")
                    .completed()
            } else{
                response.completed(status: .partialContent)
            }
        } catch {
            response.setBody(string: "Error handling request \(error)")
                .completed(status: .internalServerError)
        }
    }
    
    func countParticByIdEvent(request: HTTPRequest, response: HTTPResponse){ //WORKING
        do {
            if let idEvent = request.urlVariables["id"]{
                
                let eventPartic = EventPartic()
                
                try eventPartic.find([("idevent",idEvent)])
                
                var partics: Int = 0
                
                for _ in eventPartic.rows(){
                    partics = partics + 1
                }
                
                try response.setBody(json: ["partics": partics])
                    .setHeader(.contentType, value: "application/json")
                    .completed()
            } else {
                response.completed(status: .partialContent)
            }
        } catch {
            response.setBody(string: "Error handling request \(error)")
                .completed(status: .internalServerError)
        }
    }
    
    func deleteParticByID(request: HTTPRequest, response: HTTPResponse){
        do{
            let eventPartic = EventPartic()
            
            if let idEvent = request.urlVariables["id"]{
                
                var uuid = 0
             
                if let dict = userData as? Dictionary<String,AnyObject>{
                    if let userIdJWT = dict["id"]{
                        uuid = userIdJWT as! Int
                        
                        let cursor = StORMCursor(limit: 1, offset: 0)
                        
                        try eventPartic.select(whereclause: "idevent = $1 and uuid = $2", params: [idEvent, uuid], orderby: [], cursor: cursor)
                        
                        if eventPartic.id != 0{
                            
                            try eventPartic.delete(eventPartic.id)
                           
                            try response.setBody(json: ["message": "DELETED"])
                                .setHeader(.contentType, value: "application/json")
                                .completed(status: .gone)
                            
                        } else{
                            response.completed(status: .notFound)
                        }
                    }
                } else{
                    response.completed(status: .notFound)
                }
                
            }  else {
                  response.completed(status: .partialContent)
            }
         
        } catch {
            response.setBody(string: "Error handling request \(error)")
                .completed()
        }
    }
    
    
    func getAllEventsByUUID(request: HTTPRequest, response: HTTPResponse){
        do{
            
            let eventPartic = EventPartic()
            let event       = Event()
            
            if let dict = userData as? Dictionary<String,AnyObject>{
                if let userIdJWT = dict["id"]{
                    try eventPartic.find([("uuid", userIdJWT)])
                }
            }
            
            var eventIDs: [Any] = []
            
            for row in eventPartic.rows(){
                eventIDs.append(row.idevent)
            }
            
            var eventList: [[String:Any]] = []
            
            for eventID in eventIDs{
              
                event.id = eventID as! Int
                try event.get()
                eventList.append(event.asDictionary())
                
            }
            try response.setBody(json: eventList)
                .setHeader(.contentType, value: "application/json")
                .completed()
        } catch {
            response.setBody(string: "Error handling request \(error)")
                .completed()
        }
        
    }
    
    routes.add(method: .get, uri: "/partic_count/{id}", handler: countParticByIdEvent)
    
    routes.add(method: .get, uri: "/partic_user_events", handler: getAllEventsByUUID)
    
    routes.add(method: .get, uri: "/partic/{id}", handler: getParticByIdEvent)
    
    routes.add(method: .delete, uri: "/partic/{id}", handler: deleteParticByID)
    
    routes.add(method: .post, uri: "/partic/{id}", handler: addPartic)
    
    return routes
    
}
