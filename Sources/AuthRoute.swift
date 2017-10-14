//
//  AuthRoute.swift
//  nearby-api
//
//  Created by Andre Rosa on 03/09/17.
//
//


import PerfectLib
import PerfectHTTPServer
import PerfectHTTP
import StORM
import PostgresStORM
import PerfectCrypto

func AuthRoute () -> Routes{
    var routes = Routes()
    
    func authentication(request: HTTPRequest, response: HTTPResponse){
        
        do {
    
            let user = User()
            
            guard let emailParam = request.param(name: "email") , request.param(name: "email") != nil else { return }
            
            guard let passwordParam = request.param(name: "password")?.encrypt(.seed_ecb, password: "nearby", salt: "nearby", keyIterations: 250, keyDigest: .md5) , (request.param(name: "password") != nil) else { return }
            
            try user.find([("email",emailParam), ("password", passwordParam)])
            
            if user.id != 0 {
           
                let tstPayload = user.asDictionary() 
                
                let secret = "secret"
                guard let jwt1 = JWTCreator(payload: tstPayload) else {
                    return // fatal error
                }
                let token = try jwt1.sign(alg: .hs256, key: secret)
                
                try response.setBody(json: ["token":token])
                    .setHeader(.contentType, value: "application/json")
                    .completed()
            } else {
                response.completed(status: .unauthorized)
            }
            
        } catch {
            response.setBody(string: "Error handlin request \(error)")
                .completed(status: .internalServerError)
        }
    }
    
    
    routes.add(method: .post, uri: "/auth/login", handler: authentication)
    
    
    return routes
}
