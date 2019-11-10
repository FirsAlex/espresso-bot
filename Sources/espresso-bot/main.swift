//
// main.swift
//
// This file containing the example code is in public domain.
// Feel free to copy-paste it and edit it in any way you like.
//

import Foundation
import TelegramBotSDK
import SQLite

///Users/alexander/Desktop/espresso-bot/ESPRESSO_BOT_TOKEN"
var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/ESPRESSO_BOT_TOKEN"
//Добавлена переменная окружения
let token = readToken(from: path)
//let token = readToken(from: "/app/ESPRESSO_BOT_TOKEN") // Remote server

let bot = TelegramBot(token: token)
let controller = Controller(bot: bot)
let router = Router(bot: bot)


router[Commands.start] = controller.start
router[Commands.stop] = controller.stop
router[Commands.admin] = controller.admin
router[Commands.help] = controller.help
router[Commands.support] = controller.support
router[Commands.list] = controller.list
router[Commands.timeCofe] = controller.timeList
router[.callback_query(data: nil)] = controller.onCallbackQuery
router[Commands.add] = controller.add

// Default handler
router.unmatched = controller.help
router.unsupportedContentType = controller.help
// If command has unprocessed arguments, report them:
router.partialMatch = controller.partialMatchHandler

let db = Database()
let connect = db.connection!
connect.busyTimeout = 10
var i: Int64 = 1

let users = Table("users")
let id = Expression<Int64>("id")
let first_name = Expression<String?>("first_name")
let last_name = Expression<String?>("last_name")
let username = Expression<String?>("username")
let location = Expression<Int64>("location")
let time = Expression<String?>("time")

let locations = Table("reference_locations")
let code = Expression<Int64>("code")
let name_location = Expression<String>("name_location")

try connect.run(users.create(ifNotExists: true) { t in
    t.column(id, primaryKey: true)
    t.column(first_name)
    t.column(last_name)
    t.column(username)
    t.column(location)
    t.column(time)
})
try connect.run(locations.create(ifNotExists: true) { t in
    t.column(code, primaryKey: true)
    t.column(name_location, unique: true)
})
try connect.run(locations.delete())

for item in locationsList {
    db.addRowReferenceLocations(i, item)
    i+=1
}
    
print("Ready to accept commands")

while let update = bot.nextUpdateSync() {
	print("update: \(update.debugDescription)")
	
	try router.process(update: update)
}
print("Server stopped due to error: \(bot.lastError.unwrapOptional)")
exit(1)
