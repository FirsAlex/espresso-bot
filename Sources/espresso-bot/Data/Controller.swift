//
//  File.swift
//  
//
//  Created by Alexander Firsov on 04.11.2019.
//

import Foundation
import TelegramBotSDK
import SQLite

class Controller {
    let bot: TelegramBot

    init(bot: TelegramBot) {
        self.bot = bot
    }
    
    func start(context: Context) -> Bool {
        guard let chatId = context.chatId else { return false }
        
        guard (context.message?.chat.username != nil) else {
            context.respondAsync("Задайте никнейм в настройках Telegram!")
            return true
        }
        
        guard showMainMenu(context: context, text: "Выберите пункт меню:") else { return false }
        
        guard !db.usersContains(chatId) else {
            context.respondAsync("@\(bot.username) уже запущен.")
            return true
        }
        
        guard db.addRowUsers(chatId, context.message?.chat.firstName, context.message?.chat.lastName, context.message?.chat.username)
            else { return false }
        context.respondSync("@\(bot.username) запущен. Для остановки наберите /stop")
        return true
    }
    
    func stop(context: Context) -> Bool {
        guard let chatId = context.chatId else { return false }

        guard db.usersContains(chatId) else {
            context.respondAsync("@\(bot.username) уже остановлен.")
            return true
        }
        
        guard db.deleteRowUsers(chatId) else { return false }
        context.respondSync("@\(bot.username) остановлен. Для запуска наберите /start  <пароль регистрации>")
        return true
    }
    
    func help(context: Context) -> Bool {
        guard let chatId = context.chatId else { return false }
        guard db.usersContains(chatId) else { return false }
        let text = "Вы можете использовать пункты меню или набрать одну из команд:\n" +
            "/start - для запуска бота\n" +
            "/stop - для остановки бота\n" +
            "/list - вывод списка доступных локаций\n" +
            "/support - обратиться в поддержку\n"
        guard showMainMenu(context: context, text: text) else { return false }
        return true
    }
    
    func partialMatchHandler(context: Context) -> Bool {
        context.respondAsync("❗ Part of your input was ignored: \(context.args.scanRestOfString())")
        return true
    }

    func add(context: Context) -> Bool {
        guard let chatId = context.chatId else { return false }
        guard db.usersContains(chatId) else { return false }
        var toId: [String:AnyObject] = [:]
        var arrayUser: [[String:AnyObject]] = []
        let locateUser: Int64 = db.getLocationUsersCode(chatId)
        let locateName: String? = db.getLocationUsersName(locateUser)
        let timeUser: String? = db.getCofeTime(chatId)
        
        var button = InlineKeyboardButton()
        
        var allUsers = users.filter(id != chatId).filter(location == locateUser)
        
        do {
            if try connect.scalar(allUsers.count) != 0 && locateName != nil {
                
                allUsers = users.filter(id != chatId).filter(location == locateUser).filter(time == timeUser)
                
                if try connect.scalar(allUsers.count) == 0 {
                    allUsers = users.filter(id != chatId).filter(location == locateUser)
                }
                
                for user in try connect.prepare(allUsers) {
                    arrayUser.append(["id" : user[id] as AnyObject, "first_name" : ((user[first_name] ?? "")) as AnyObject,
                                      "last_name" : ((user[last_name] ?? "")) as AnyObject,
                                      "username" : ((user[username] ?? "")) as AnyObject])
                }
                toId = arrayUser.randomElement()!
                button.text = "Перейти в чат к: \(toId["first_name"] as! String) \(toId["last_name"] as! String)"
                button.url = "t.me/\(toId["username"] as! String)"
                var markup = InlineKeyboardMarkup()
                let keyboard = [[button]]
                markup.inlineKeyboard = keyboard
                
                context.respondAsync("Вы выбрали выпить кофе с : *\(toId["first_name"] as! String) \(toId["last_name"] as! String)*",
                parseMode: "Markdown", replyMarkup: markup)
                bot.forwardMessageAsync(chatId: toId["id"] as! Int64, fromChatId: chatId, messageId: context.message!.messageId)
                bot.sendMessageAsync(chatId: toId["id"] as! Int64, text: timeUser ?? "В любоне время")
            
            }
            else {
                context.respondAsync("В вашей локации '\(locateName ?? "<нет локации у пользователя>")' нет подписчиков ")
                return true
            }
                
        }
        catch {
            print("Failed out list Users")
            return false
        }
                
        return true
    }
    
    func support(context: Context) -> Bool {
        guard let chatId = context.chatId else { return false }
        guard db.usersContains(chatId) else { return false }
        var button = InlineKeyboardButton()
        button.text = "Поддержка"
        button.url = "t.me/MikhaylovAV"
        
        var markup = InlineKeyboardMarkup()
        let keyboard = [[button]]
        markup.inlineKeyboard = keyboard

        context.respondAsync("Нажмите кнопку для связи с поддержкой *EspressoBot Support*.",
                             parseMode: "Markdown", replyMarkup: markup)
        return true
    }
    
    func list(context: Context) -> Bool {
        guard let chatId = context.chatId else { return false }
        guard db.usersContains(chatId) else { return false }
        var keyboard = [[InlineKeyboardButton]]()
        var button = InlineKeyboardButton()
        
        do {
            for item in try connect.prepare(locations) {
                button.text = item[name_location]
                button.callbackData = "location!" + item[name_location]
                keyboard.append([button])
            }
        }
        catch {
            print("Failed out list Locations")
            return false
        }
        
        var markup = InlineKeyboardMarkup()
        markup.inlineKeyboard = keyboard
        context.respondAsync("Список доступных локаций:", replyMarkup: markup)
        return true
    }
    
    func showMainMenu(context: Context, text: String) -> Bool {
           // Use replies in group chats, otherwise bot won't be able to see the text typed by user.
           // In private chats don't clutter the chat with quoted replies.
           let replyTo = context.privateChat ? nil : context.message?.messageId
           
           var markup = ReplyKeyboardMarkup()
           //markup.oneTimeKeyboard = true
           markup.resizeKeyboard = true
           markup.selective = replyTo != nil
           markup.keyboardStrings = [
               [ Commands.add[0], Commands.list[0] ],
               [Commands.timeCofe[0]],
               [ Commands.help[0], Commands.support[0] ]]
        
           context.respondAsync(text,
               replyToMessageId: replyTo, // ok to pass nil, it will be ignored
               replyMarkup: markup)
           return true
    }
    
     func onCallbackQuery(context: Context) throws -> Bool {
        guard let callbackQuery = context.update.callbackQuery else { return false }
        guard let data = callbackQuery.data else { return false }
        guard let chatId = context.chatId else { return false }
        
        if data.contains("location"){
            guard db.updateLocationUsers(chatId, String(data.split(separator: "!")[1])) else { return false }
        }
        else if data.contains("time"){
            guard db.updateTimeUsers(chatId, String(data.split(separator: "!")[1])) else { return false }
        }
        
        context.respondAsync("Вы выбрали: \(data.split(separator: "!")[1])")
        return true
    }
    
    func timeList(context: Context) -> Bool {
        guard let chatId = context.chatId else { return false }
        guard db.usersContains(chatId) else { return false }
        var keyboard = [[InlineKeyboardButton]]()
        var button = InlineKeyboardButton()
        
            for item in timeListName {
                button.text = item
                button.callbackData = "time!" + item
                keyboard.append([button])
            }

        var markup = InlineKeyboardMarkup()
        markup.inlineKeyboard = keyboard
        context.respondAsync("Список доступного времени для приглашения на кофе:", replyMarkup: markup)
        return true
    }
}
