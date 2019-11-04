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
    var startedInChatId = Set<Int64>()

    init(bot: TelegramBot) {
        self.bot = bot
    }
    
    func start(context: Context) -> Bool {
        guard let chatId = context.chatId else { return false }
        guard showMainMenu(context: context, text: "Выберите пункт меню:") else { return false }
        
        guard !db.UsersContains(chatId) else {
            context.respondAsync("@\(bot.username) уже запущен.")
            return true
        }
        
       guard db.addRowUsers(chatId, context.message?.chat.firstName, context.message?.chat.lastName) else { return false }
        context.respondSync("@\(bot.username) запущен. Для остановки наберите /stop")
        return true
    }
    
    func stop(context: Context) -> Bool {
        guard let chatId = context.chatId else { return false }

        guard db.UsersContains(chatId) else {
            context.respondAsync("@\(bot.username) уже остановлен.")
            return true
        }
        
        guard db.deleteRowUsers(chatId) else { return false }
        context.respondSync("@\(bot.username) остановлен. Для запуска наберите /start")
        return true
    }
    
    func help(context: Context) -> Bool {
        guard let chatId = context.chatId else { return false }
        guard db.UsersContains(chatId) else { return false }
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

    func reverseText(context: Context) -> Bool {
        guard let chatId = context.chatId else { return false }
        guard db.UsersContains(chatId) else { return false }
        
        do {
            for user in try connect.prepare(users) {
                context.respondAsync("id: \(user[id]), first_name: \(user[first_name] ?? "" )," +
                                    " last_name: \(user[last_name] ?? ""), location: \(user[location])")
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
        guard db.UsersContains(chatId) else { return false }
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
        guard db.UsersContains(chatId) else { return false }
        
        let items: [String] = ["Москва: Летниковская",
                               "Москва: Спартаковская",
                               "Москва: Котельническая",
                               "Москва: Электрозаводская",
                               "Саратов: Орджоникидзе",
                               "Саратов: Шелковичная",
                               "Новосибирск: Добролюбова",
                               "Новосибирск: Кирова",
                               "Казань: Лево-Булачная",
                               "Екатеринбург: Толмачева",
                               "Хабаровск: Амурский бульвар",
                               "Ханты-Мансийск: Мира"]
        var keyboard = [[InlineKeyboardButton]]()
        
        for item in items {
            var button = InlineKeyboardButton()
            button.text = item
            button.callbackData = "toggle \(item.split(separator: ".").first ?? "0")"
            keyboard.append([button])
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
        let scanner = Scanner(string: data)

        // "toggle 1234567"
        guard scanner.skipString("toggle ") else { return false }
            if #available(OSX 10.15, *) {
                guard let itemId = scanner.scanInt64() else { return false }
                context.respondAsync("Вы выбрали: \(itemId)")
            } else {// Fallback on earlier versions
            }
        
        return true
    }
}
