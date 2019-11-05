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
        guard showMainMenu(context: context, text: "Выберите пункт меню:") else { return false }
        
        guard !db.usersContains(chatId) else {
            context.respondAsync("@\(bot.username) уже запущен.")
            return true
        }
        
       guard db.addRowUsers(chatId, context.message?.chat.firstName, context.message?.chat.lastName) else { return false }
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
        context.respondSync("@\(bot.username) остановлен. Для запуска наберите /start")
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
        
        let allUsers = users.filter(id != chatId).filter(location == locateUser)
        
        do {
            guard try connect.scalar(allUsers.count) != 0 else {
                context.respondAsync("В вашей локации '\(locateName ?? "<нет локации у пользователя>")' нет подписчиков ")
                return true
            }
            
            for user in try connect.prepare(allUsers) {
                arrayUser.append(["id" : user[id] as AnyObject, "name" : ((user[first_name] ?? "") + " " + (user[last_name] ?? "")) as AnyObject])
            }
            toId = arrayUser.randomElement()!
            
            context.respondAsync("Вы выбрали выпить кофе с : <\(toId["name"] as! String)> дождитесь от него ответа")
            bot.forwardMessageAsync(chatId: chatId, fromChatId: toId["id"] as! Int64, messageId: context.message!.messageId)
            bot.forwardMessageAsync(chatId: toId["id"] as! Int64, fromChatId: chatId, messageId: context.message!.messageId)
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
                button.callbackData = item[name_location]
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
               [ Commands.help[0], Commands.support[0] ]
           ]
           context.respondAsync(text,
               replyToMessageId: replyTo, // ok to pass nil, it will be ignored
               replyMarkup: markup)
           return true
    }
    
     func onCallbackQuery(context: Context) throws -> Bool {
        guard let callbackQuery = context.update.callbackQuery else { return false }
        guard let data = callbackQuery.data else { return false }
        guard let chatId = context.chatId else { return false }
        
        guard db.updateLocationUsers(chatId, data) else { return false }
        context.respondAsync("Вы выбрали: \(data)")
        return true
    }
}
