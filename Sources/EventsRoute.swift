//
//  EventsRoute.swift
//  nearby-API
//
//  Created by Andre Rosa on 31/08/17.
//
//

import PerfectLib
import PerfectHTTPServer
import PerfectHTTP
import PerfectThread
import StORM
import PostgresStORM


func EventsRoute() -> Routes{
 
    var routes = Routes()
    
    func createEvent(request: HTTPRequest, response: HTTPResponse){ //working
        do{
            let user = User()
            
            if let dict = userData as? Dictionary<String,AnyObject>{
                if let userIdJWT = dict["id"]{
                    user.id = userIdJWT as! Int
                }
            }
            
            let event           = Event()
            event.name          = request.param(name: "name")!
            event.description   = request.param(name: "description")!
            event.eventType     = request.param(name: "eventType")!
            event.location      = request.param(name: "location")!
            event.eventDate     = request.param(name: "eventDate")!
            event.criator       = user.id
            
            try event.save{ id in event.id = id as! Int }
            
            let eventPartic     = EventPartic()
            eventPartic.uuid    = user.id
            try eventPartic.save{ id in eventPartic.id = id as! Int }
    
            try response.setBody(json: ["message": "CREATED"])
                .setHeader(.contentType, value: "application/json")
                .completed(status: .created)
            
        } catch {
            response.setBody(string: "Error handling request \(error)")
                .completed(status: .internalServerError)
        }
    }
    
    func updateEventByID(request: HTTPRequest, response: HTTPResponse){ //working
        do {
            let params = request.params()
          
            if let idObj = request.urlVariables["id"]{
                
                var objModel = [(String, Any)]()
                
                for (k,v) in params{
                    objModel.append((k,v))
                }
                
                let event = Event()
                
                if let dict = userData as? Dictionary<String,AnyObject>{
                    if let userIdJWT = dict["id"]{
                        try event.find([("id", idObj), ("criator",userIdJWT)])
                        
                        if event.id != 0{
                            
                            try event.update(
                                data: objModel,
                                idName: "id",
                                idValue: idObj
                            )
                            
                            try response.setBody(json: ["message": "UPDATED"])
                                .setHeader(.contentType, value: "application/json")
                                .completed(status: .ok)
                        }  else{
                            response.completed(status: .notFound)
                        }
                    }
                }
            } else {
                response.completed(status: .expectationFailed)
            }
          
        } catch {
            response.setBody(string: "Error handling request \(error)")
                .completed(status: .internalServerError)
        }
    }
    func getAllEvents(request: HTTPRequest, response: HTTPResponse){ //working
        do {
          
            let event = Event()
            
            try event.findAll()
            
            var events: [[String: Any]] = []
            
            for row in event.rows(){
                events.append(row.asDictionary())
            }
            
            try response.setBody(json: events)
                .setHeader(.contentType, value: "application/json")
                .completed()
        } catch {
            response.setBody(string: "Error handling request \(error)")
                .completed(status: .internalServerError)
        }
    }
    
    func getEventByID(request: HTTPRequest, response: HTTPResponse){ //working
        do {
    
            if let idObj = request.urlVariables["id"]{
                
                let event = Event()
                
                event.id = Int(idObj)!
                
                try event.get()
                
                try response.setBody(json: event.asDictionary())
                    .setHeader(.contentType, value: "application/json")
                    .completed()
            } else {
                response.completed(status: .preconditionFailed)
            }
            
        } catch {
            response.setBody(string: "Error handling request \(error)")
            .completed(status: .internalServerError)
        }
    }
    
    func getEventByCriator(request: HTTPRequest, response: HTTPResponse){ //working
        do {
            
            let event = Event()
            
            if let dict = userData as? Dictionary<String,AnyObject>{
                if let userIdJWT = dict["id"]{
                    try event.find([("criator",userIdJWT)])
                }
            }
            
            var events: [[String: Any]] = []
            
            for row in event.rows(){
                events.append(row.asDictionary())
            }
            
            try response.setBody(json: events)
                .setHeader(.contentType, value: "application/json")
                .completed()
        } catch {
            response.setBody(string: "Error handling request \(error)")
                .completed(status: .internalServerError)
        }
    }

    
    func deleteEventByID(request: HTTPRequest, response: HTTPResponse){ //WORKING
        do{
    
            if let idObj = request.urlVariables["id"]{
                let event = Event()
                let eventPartic = EventPartic()
                
                if let dict = userData as? Dictionary<String,AnyObject>{
                    if let userIdJWT = dict["id"]{
                        try event.find([("id", idObj), ("criator",userIdJWT)])
                        if event.id != 0{
                            try event.delete(event.id)
                            
                            try eventPartic.find([("idevent", event.id)])
                            
                            for row in eventPartic.rows(){
                                try eventPartic.delete(row.id)
                            }
                            
                            try response.setBody(json: ["message": "DELETED"])
                                .setHeader(.contentType, value: "application/json")
                                .completed(status: .gone)
                        } else{
                            response.completed(status: .partialContent)
                        }
                    }
                }
            } else {
                  response.completed(status: .partialContent)
            }
            
        } catch {
            response.setBody(string: "Error handling request \(error)")
            .completed()
        }
    }
    
    routes.add(method: .get, uri: "/events", handler: getAllEvents)
    
    routes.add(method: .delete, uri: "/events/{id}", handler: deleteEventByID)
    
    routes.add(method: .get, uri: "/events/{id}", handler: getEventByID)
    
    routes.add(method: .get, uri: "/my_events", handler: getEventByCriator)
    
    routes.add(method: .patch, uri: "/events/{id}", handler: updateEventByID)
    
    routes.add(method: .post, uri: "/events", handler: createEvent)
    
    return routes
}
