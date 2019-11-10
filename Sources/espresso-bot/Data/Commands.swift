//
// Telegram Bot SDK for Swift (unofficial).
//
// This file containing the example code is in public domain.
// Feel free to copy-paste it and edit it in any way you like.
//

import Foundation

struct Commands {
    static let start = "start"
    static let stop = "stop"
    static let admin = "admin"
    static let help = ["ℹ️ Помощь", "help"]
    static let add = ["☕ Выпить кофе", "add"]
    static let list = ["🌐 Выбрать локацию", "list"]
    static let timeCofe = ["⏱️ Выбрать время", "time"]
    static let support = ["✉️ Поддержка", "support"]
}

let locationsList: [String] = ["Москва: Летниковская",
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


let timeListName: [String] = ["Сейчас",
"В течение получаса",
"Через час",
"Завтра",
"Послезавтра",
"В любое время"]
