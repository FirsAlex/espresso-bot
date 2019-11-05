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
    
    func addRowUsers(_ vId: Int64,_ vFirst_name: String?,_ vLast_name: String?,_ vCodeLocation: Int64 = 0) -> Bool {
        do {
            try connect.run(users.insert(id <- vId, first_name <- vFirst_name, last_name <- vLast_name, location <- vCodeLocation))
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
    
    func addRowReferenceLocations(_ vCode: Int64,_ vLocation: String) {
        do {
            try connect.run(locations.insert(code <- vCode, name_location <- vLocation))
        } catch let Result.error(message, code, nil) {
            print("Failed addRowLocations: \(message), code: \(code)")
        }
        catch let error {
            print("Failed addRowLocations: \(error)")
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
    
    func usersContains(_ vId: Int64) -> Bool{
        let user = users.filter(id == vId)
        do {
            let count = try connect.scalar(user.count)
            return (count == 0) ? false : true
        }
        catch {
            return false
        }
    }
    
    func updateLocationUsers(_ vId: Int64, _ vNameLocation: String) -> Bool {
        let user = users.filter(id == vId)
        let loc = locations.filter(name_location == vNameLocation)
        do {
            for codes in try connect.prepare(loc){
                try connect.run(user.update(location <- codes[code]))
            }
       } catch {
           print("updated failed: \(error)")
           return false
       }
        return true
   }
    
    func getLocationUsersCode(_ vId: Int64) -> Int64 {
        let user = users.filter(id == vId)
        do {
            for codes in try connect.prepare(user){
                return codes[location]
            }
       } catch {
           print("updated failed: \(error)")
           return -1
       }
        return -2
   }
    
    func getLocationUsersName(_ vCode: Int64) -> String? {
         let locname = locations.filter(code == vCode)
         do {
             for name in try connect.prepare(locname){
                 return name[name_location]
             }
        } catch {
            print("updated failed: \(error)")
            return nil
        }
         return nil
    }
    
}
