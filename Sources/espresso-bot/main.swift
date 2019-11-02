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
        
		guard !started(in: chatId) else {
            context.respondAsync("@\(bot.username) already started.")
            return true
        }
        startedInChatId.insert(chatId)
        
		guard showMainMenu(context: context, text: "Please choose an option.") else { return false }
        return true
    }
    
	func stop(context: Context) -> Bool {
        guard let chatId = context.chatId else { return false }

        guard started(in: chatId) else {
            context.respondAsync("@\(bot.username) already stopped.")
            return true
        }
		startedInChatId.remove(chatId)
		
        context.respondSync("@\(bot.username) stopped. To restart, type /start")
		return true
    }
    
    func help(context: Context) -> Bool {
        let text = "Usage:\n" +
            "/start - to begin" +
            "/stop - to end" +
            "/support - join the support group"
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
		
        let text = context.args.scanRestOfString()
	
        context.respondAsync(String(text.reversed()))
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
               [ Commands.add[0], Commands.list[0], Commands.delete[0] ],
               [ Commands.help[0], Commands.support[0] ]
           ]
           context.respondAsync(text,
               replyToMessageId: replyTo, // ok to pass nil, it will be ignored
               replyMarkup: markup)
           return true
       }
    
    func support(context: Context) -> Bool {
        var button = InlineKeyboardButton()
        button.text = "Support"
        button.url = "t.me/MikhaylovAV"
        
        var markup = InlineKeyboardMarkup()
        let keyboard = [[button]]
        markup.inlineKeyboard = keyboard

        context.respondAsync("Please click the button below to join *Espresso Bot Support* group.", parseMode: "Markdown", replyMarkup: markup)

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
router["reverse", .slashRequired] = controller.reverseText

// Default handler
router.unmatched = controller.reverseText
// If command has unprocessed arguments, report them:
router.partialMatch = controller.partialMatchHandler

print("Ready to accept commands")
while let update = bot.nextUpdateSync() {
	print("--- update: \(update.debugDescription)")
	
	try router.process(update: update)
}
print("Server stopped due to error: \(bot.lastError.unwrapOptional)")
exit(1)
