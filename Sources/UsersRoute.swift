
import PerfectLib
import PerfectHTTPServer
import PerfectHTTP
import StORM
import PostgresStORM
import PerfectCrypto

func UsersRoute() -> Routes {
    
    var routes = Routes()

    func newUser (request: HTTPRequest, response: HTTPResponse) { //working
        do {
            
            let senhaParam = request.param(name: "password")!
            
            let user = User()
            user.name = request.param(name: "name")!
            user.email = request.param(name: "email")!
            user.password = senhaParam.encrypt(.seed_ecb, password: "nearby", salt: "nearby", keyIterations: 250, keyDigest: .md5)!
            
            try user.find([("email", user.email)])
            
            if(user.id == 0){
                try user.save{ id in user.id = id as! Int }
                
                try response.setBody(json: ["message": "INSERTED"])
                    .setHeader(.contentType, value: "application/json")
                    .completed(status: .created)
            } else{
                response.completed(status: .conflict)
            }
            
            
       
        } catch {
            response.setBody(string: "Error handling request \(error)")
                .completed(status: .internalServerError)
        }
    }
    
    func editUser (request: HTTPRequest, response: HTTPResponse){ //working
        do {

            let params = request.params()
            
            if let dic = userData as? Dictionary<String,AnyObject>{
                
                
                if let userIdJWT = dic["id"]{
                    
                    var objModel = [(String,Any)]()
                    
                    for (k,v) in params{
                        objModel.append((k,v))
                    }
                    
                    let user = User()
                    
                    try user.update(
                        data: objModel,
                        idName: "id",
                        idValue: userIdJWT
                    )
                    
                    try response.setBody(json: ["message": "UPDATED"])
                        .setHeader(.contentType, value: "application/json")
                        .completed(status: .ok)
                }
            } else{
                response.completed(status: .notFound)
            }
            
            
        } catch {
            response.setBody(string: "Error handling request \(error)")
                .completed(status: .internalServerError)
        }
    }
    
    func getUserByID(request: HTTPRequest, response: HTTPResponse){   //working
        do {
            let user = User()
 
            
            if let dic = userData as? Dictionary<String,AnyObject>{
                if let userIdJWT = dic["id"] {
                    try user.find([("id", userIdJWT)])
                    try response.setBody(json: user.asDictionary())
                        .setHeader(.contentType, value: "application/json")
                        .completed()
                } else{
                  response.completed(status: .notFound)
                }
            }
            
        } catch {
            response.setBody(string: "Error handlin request \(error)")
                .completed(status: .internalServerError)
        }
    }
    
    // na criacao colocar o retorno 204

    
    routes.add(method: .get, uri: "/users", handler: getUserByID)
    routes.add(method: .post, uri: "/users/new", handler: newUser)
    routes.add(method: .patch, uri: "/users", handler: editUser)
    
    
    return routes
}


