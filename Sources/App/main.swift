import Vapor
import MongoKitten

/*
 https://vapor.github.io/documentation/getting-started/install-swift-3-macos.html
 https://medium.com/@joannis.orlandos/using-mongokitten-vapor-for-your-applications-24dbac2f5dd9#.sdoilt93s
 */

do {
    
    let drop = Droplet()
    
    drop.get("hello") { request in
        
        // magic happens inside the 'GET' completion handler
        let server = try Server(mongoURL: "mongodb://localhost:27017")
        let database = server["sample"]
        
        if server.isConnected {
            print("Successful connection to server")
        }
        
        return "Hello, & welcome, world!"
    }
    
    drop.resource("posts", PostController())
    
    drop.run()
} catch {
    print("Cannot connect to MongoDB")
}


