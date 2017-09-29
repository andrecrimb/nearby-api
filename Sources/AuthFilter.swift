//
//  AuthFilter.swift
//  nearby-api
//
//  Created by Andre Rosa on 18/09/17.
//
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectCrypto

struct authenticationFilter: HTTPRequestFilter {
    func filter(request: HTTPRequest, response: HTTPResponse, callback: (HTTPRequestFilterResult) -> ()) {
      //colocar uma expiracao no token
        print(request.uri)
        print(userData)
        do{
            if !request.uri.contains(string: "/auth/login") && !request.uri.contains(string: "/users/new"){
                
                if let token = request.header(.authorization){

                    guard let jwt = JWTVerifier(token) else {
                        return
                    }
                    try jwt.verify(algo: .hs256, key: HMACKey("secret"))
                    
                    print("\(token) --- Json")
                    
                    if let idUser = jwt.payload["id"] as? Int{
                        let user = User()
                        
                        user.id = idUser
                    
                        try user.get()
        
                        userData = user.asDictionary()
                        
                        callback(.continue(request, response))
                    }
                } else {
                  response.completed(status: .unauthorized)
                }
            } else{
                callback(.continue(request, response))
            }
        } catch {
                response.completed(status: .unauthorized)
        }
    }
}
