//
// main.swift
//
// This file containing the example code is in public domain.
// Feel free to copy-paste it and edit it in any way you like.
//

import Foundation
import TelegramBotSDK

let token = readToken(from: "/Users/alexander/Desktop/espresso-bot/ESPRESSO_BOT_TOKEN")

class Controller {
    let bot: TelegramBot
    var startedInChatId = Set<Int64>()
	
	func started(in chatId: Int64) -> Bool {
		return startedInChatId.contains(chatId)
 	}

    init(bot: TelegramBot) {
        self.bot = bot
    }
    
	func start(context: Context) -> Bool {
        guard let chatId = context.chatId else { return false }
        guard showMainMenu(context: context, text: "Выберите пункт меню:") else { return false }
		
        guard !started(in: chatId) else {
            context.respondAsync("@\(bot.username) уже запущен.")
            return true
        }
        startedInChatId.insert(chatId)
        
		
        return true
    }
    
	func stop(context: Context) -> Bool {
        guard let chatId = context.chatId else { return false }

        guard started(in: chatId) else {
            context.respondAsync("@\(bot.username) уже остановлен.")
            return true
        }
		startedInChatId.remove(chatId)
		
        context.respondSync("@\(bot.username) остановлен. Для запуска наберите /start")
		return true
    }
    
    func help(context: Context) -> Bool {
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
		guard started(in: chatId) else { return false }
		
        context.respondAsync("Подписано \(startedInChatId.count) пользователей.")
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
    
    func support(context: Context) -> Bool {
        var button = InlineKeyboardButton()
        button.text = "Поддержка"
        button.url = "t.me/MikhaylovAV"
        
        var markup = InlineKeyboardMarkup()
        let keyboard = [[button]]
        markup.inlineKeyboard = keyboard

        context.respondAsync("Нажмите кнопку для связи с поддержкой *EspressoBot Support*.", parseMode: "Markdown", replyMarkup: markup)

        return true
    }
    
    func list(context: Context) -> Bool {
        guard let markup = itemListInlineKeyboardMarkup(context: context) else { return false }
        context.respondAsync("Список доступных локаций:",
                             replyMarkup: markup)
        return true
    }
    
    func itemListInlineKeyboardMarkup(context: Context) -> InlineKeyboardMarkup? {
        let items: [String] = ["1.  Москва: Летниковская",
                               "2.  Москва: Спартаковская",
                               "3.  Москва: Котельническая",
                               "4.  Москва: Электрозаводская",
                               "5.  Саратов: Орджоникидзе",
                               "6.  Саратов: Шелковичная",
                               "7.  Новосибирск: Добролюбова",
                               "8.  Новосибирск: Кирова",
                               "9.  Казань: Лево-Булачная",
                               "10. Екатеринбург: Толмачева",
                               "11. Хабаровск: Амурский бульвар",
                               "12. Ханты-Мансийск: Мира"]
        
        var keyboard = [[InlineKeyboardButton]]()
        for item in items {
            var button = InlineKeyboardButton()
            button.text = item
            button.callbackData = "toggle \(item.split(separator: ".").first ?? "0")"
            keyboard.append([button])
        }
        
        var markup = InlineKeyboardMarkup()
        markup.inlineKeyboard = keyboard
        return markup
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

let bot = TelegramBot(token: token)
let controller = Controller(bot: bot)

let router = Router(bot: bot)
router[Commands.start] = controller.start
router[Commands.stop] = controller.stop
router[Commands.help] = controller.help
router[Commands.support] = controller.support
router[Commands.list] = controller.list
router[.callback_query(data: nil)] = controller.onCallbackQuery

// Default handler
router.unmatched = controller.reverseText
// If command has unprocessed arguments, report them:
router.partialMatch = controller.partialMatchHandler

print("Ready to accept commands")
while let update = bot.nextUpdateSync() {
	print("update: \(update.debugDescription)")
	
	try router.process(update: update)
}
print("Server stopped due to error: \(bot.lastError.unwrapOptional)")
exit(1)
