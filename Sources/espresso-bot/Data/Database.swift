//
//  File.swift
//  
//
//  Created by Alexander Firsov on 04.11.2019.
//

import Foundation
import SQLite

class Database {
    
    public let connection: Connection?
    
    init(){
        do {
            let dbPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/DB.db"
            self.connection = try Connection(dbPath)
        } catch {
            self.connection = nil
            let nserror = error as NSError
            print ("Cannot connect to Database. Error is: \(nserror), \(nserror.userInfo)")
        }
    }
    
    func addRowUsers(_ vId: Int64,_ vFirst_name: String?,_ vLast_name: String?,_ vLocation: Int64 = 0) -> Bool {
        do {
            try connect.run(users.insert(id <- vId, first_name <- vFirst_name, last_name <- vLast_name, location <- vLocation))
            return true
        } catch let Result.error(message, code, nil) {
            print("Failed addRowUsers: \(message), code: \(code)")
            return false
        }
        catch let error {
            print("Failed addRowUsers: \(error)")
            return false
        }
    }
    
    func deleteRowUsers(_ vId: Int64) -> Bool {
        let user = users.filter(id == vId)
        
        do {
            if try connect.run(user.delete()) > 0 {
                print("Deleted User ID: \(vId)")
            } else {
                print("User not found ID: \(vId)")
            }
            return true
        } catch {
            print("delete failed: \(error)")
            return false
        }
    }
    
    func UsersContains(_ vId: Int64) -> Bool{
        let user = users.filter(id == vId)
        do {
            let count = try connect.scalar(user.count)
            return (count == 0) ? false : true
        }
        catch {
            return false
        }
    }
    
}
