# ESSPRESSO BOT
Bot для платформы Telegram написанный на языке Swift, предназначен для случайного приглашения на чашку кофе двух человек находящихся в одной локации.

# Первый запуск
Перед запуском обязательно необходимо настроить @username в профиле пользователя Telegram, это необходимо для отправки контакта для приглашения на кофе.

  ![username](https://cdn1.savepice.ru/uploads/2019/11/10/9329cf3eba4782f834818a01f7af3e0f-full.png)

# Подключится к боту возможно одним из следующих способов:

  - с помощью ссылки t.me/EspressBot
  - с помощью QRCode
  
  ![qrcode](https://cdn1.savepice.ru/uploads/2019/11/10/8d2e06479cdab126d1b1f98865094fee-full.png)
  
  - с помощью поиска Telegram по имени @EspressBot
  - нажать кнопку СТАРТ
  
  ![start](https://cdn1.savepice.ru/uploads/2019/11/10/54c53459618c0907cae8ec4317663ec0-full.jpg)
  
  - для регистрации в боте набрать команду /start<пробел><пароль> (ПР: /start 111 - для тестирования)
  - далее необходимо <🌐 Выбрать локацию> с помошью соответствующей кнопки, в противном случае при нажатии на кнопку <☕ Выпить кофе> произойдет ошибка.
  ```
"Москва: Летниковская",
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
"Ханты-Мансийск: Мира"
```
  - делее если это необходимо можно уточнить желаемое время приглашения на кофе с помощью кнопки ⏱️ Выбрать время
```
"Сейчас",
"В течение получаса",
"Через час",
"Завтра",
"Послезавтра",
"В любое время"
```
По умолчанию (если вы не выбрали время) каждому пользователю присваивается "В любое время"
>После этого необходимо нажать кнопку <☕ Выпить кофе>  
>Вам и случайно выбранному пользователю будут отправленны ссылки на приватный чат.
![invite](https://cdn1.savepice.ru/uploads/2019/11/10/8ad77de9078b616ffb731fbb2a30c392-full.jpg)

Вы так же можете:
  - Отменить регистрацию и удалить все данные пользователя возможно по команде /stop
  - Команда администратора /admin<пробел><пароль админа><новый пароль регистрации пользователей>
  (ПР: /admin 000 444)

P.S. Иногда кнопки в интерфейсе телеграма могут сворачиваться в квадратик с 4-мя точками, например когда появляется клавиатура, что бы кнопки появились снова просто нажмите на этот квадратик.

![button](https://cdn1.savepice.ru/uploads/2019/11/11/7b42f9217d7371cb5da73aed51f8b473-full.jpg

# Алгоритм поиска пользователей для приглашения на кофе
Из общего списка выделяются пользователи имеющие туже локацию и желаемое время, среди них случайным образом выбирается один пользователь, если же таких пользователей нет, то отсев происходит среди пользователей имеющих ту же локацию.


# Инфраструктура
Проект размещен на виртуальном сервере https://itldc.com/
Для размещения на сервере были установлены соответствующие библиотеки SQLlite и Swift для компиляции и запуска приложения

На этом же сервере располагаются: 
  - файл базы данных
  - token бота
  - пароль администратора

# Исходный код
В папке с исходным кодом располагаются следующие файлы: 
  - Commands.swift (константные выражения для заполнения команд бота и кнопок, наименования локаций для таблицы БД - справочника локаций, константы для заполнения списка доступных времён)
  - Database.swift (класс БД, содержащий инициализацию с подключением к БД, а также различные методы для работы с таблицами БД - удаление, вставка, изменение. Класс можно дополнять по мере расширения функционала)
  - Controller.swift (класс, содержащий методы для обработки команд пользователя, поступающих из командной строки либо посредством нажатия кнопки - onCallbackQuery)
 - main.swift (главный файл - точка входа, в нём соотносятся команды с методами класса Controller, которые будут их обрабатывать. Также в main происходит создание таблиц БД с заданными полями, заполнение таблицы справочника локаций.) 
