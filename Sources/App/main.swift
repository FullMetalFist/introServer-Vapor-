import Vapor
import MongoKitten

let drop = Droplet()

/*
 https://vapor.github.io/documentation/getting-started/install-swift-3-macos.html
 https://medium.com/@joannis.orlandos/using-mongokitten-vapor-for-your-applications-24dbac2f5dd9#.sdoilt93s
 */

do {
    
    let mongoDB = try Database(mongoURL: "mongodb://localhost:27017/sample")
    let users = mongoDB["users"]
    
    drop.get("/") { request in
        
        // check that there is a Vapor session
        let session = try request.session()
        
        // find user ID
        if let userID = session.data["user"]?.string {
            // check if the user is ours
            guard let userDocument = try users.findOne(matching: "_id" == ObjectId(userID)) else {
                // if we don't know the user, boot
                return "I don't know you"
            }
            
            // if we know the user
            return "Welcome, \(userDocument["username"] as String? ?? "")."
        }
        
        // if the user has sent username & password over POST/PUT/GET/DELETE
        if let username = request.data["username"] as String?, let password = request.data["password"] as String? {
            let passwordHash = try drop.hash.make(password)
            
            // when the user wants to register
            if request.data["register"]?.bool = true {
                // if the username exists
                guard try users.count(matching: "username" == username) == 0 else {
                    return "User with that username already exists"
                }
                
                // register the user by inserting his information in the database
                guard let id = try users.insert(["username": username, "password": passwordHash] as Document).string else {
                    return "Unable to automatically log in"
                }
                
                session.data["user"] = Node.string(id.string ?? "")
                return "Thank you for registering \(username). You are automatically logged in"
            }
            
            // try to log the user in
            guard let user = try users.findOne(matching: "username" == username && "password" == passwordHash), let userId = user["_id"] as String? else {
                return "The username or password is incorrect"
            }
            
            // create a session for the user
            session.data["user"] = Node.string(userId)
            return "Your login as \(username) was successful"
        }
        
        // if there is no submitted username or password AND the user isn't logged in
        
        return "Hello, & welcome, world!"
    }
    
    drop.resource("posts", PostController())
    
    drop.run()
} catch {
    print("Cannot connect to MongoDB")
}


