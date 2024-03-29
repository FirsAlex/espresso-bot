// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "espresso-bot",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .executable(
            name: "espresso-bot",
            targets: ["espresso-bot"]),
        ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/zmeyc/telegram-bot-swift.git", from: "1.2.3"),
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.12.2"),
        ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "espresso-bot",
            dependencies: ["TelegramBotSDK","SQLite"]),
        ]
)
