import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectCrypto

import StORM
import PostgresStORM

let db = setupDBCredentials()

var userData: JSONConvertible = []


let setupUser = User()
try? setupUser.setup()

let setupEventPartic = EventPartic()
try? setupEventPartic.setup()

let setupEvent = Event()
try? setupEvent.setup()

let server = HTTPServer()
server.serverPort = 8080

let usersRoute = UsersRoute()
let authRoute = AuthRoute()
let eventsRoute = EventsRoute()
let eventsParticRoute = EventsParticRoute()

server.addRoutes(usersRoute)
server.addRoutes(authRoute)
server.addRoutes(eventsRoute)
server.addRoutes(eventsParticRoute)

let requestFilters: [(HTTPRequestFilter, HTTPFilterPriority)] = [(authenticationFilter(), HTTPFilterPriority.high)]

server.setRequestFilters(requestFilters)

do {
    try server.start()
} catch PerfectError.networkError(let err, let msg) {
    print("Network error thrown: \(err) \(msg)")
}
