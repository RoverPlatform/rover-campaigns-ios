// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RoverCampaigns",
    platforms: [.iOS(SupportedPlatform.IOSVersion.v10)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Foundation",
            targets: ["Foundation"]),
        .library(
            name: "Data",
            targets: ["Data"]),
        .library(
            name: "UI",
            targets: ["UI"]),
        .library(
            name: "Experiences",
            targets: ["Experiences"]),
        .library(
            name: "Notifications",
            targets: ["Notifications"]),
        .library(
            name: "Location",
            targets: ["Location"]),
        .library(
            name: "Bluetooth",
            targets: ["Bluetooth"]),
        .library(
            name: "Debug",
            targets: ["Debug"]),
        .library(
            name: "Telephony",
            targets: ["Telephony"]),
        .library(
            name: "AdSupport",
            targets: ["AdSupport"]),
        .library(
            name: "Ticketmaster",
            targets: ["Ticketmaster"]),
        .library(
            name: "AppExtensions",
            targets: ["AppExtensions"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/RoverPlatform/rover-ios", .branch("feature/swift-pm"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Foundation",
            dependencies: [],
            path: "Sources/Foundation"),
        .target(
            name: "Data",
            dependencies: ["Foundation"],
            path: "Sources/Data"),
        .target(
            name: "UI",
            dependencies: ["Data"],
            path: "Sources/UI"),
        .target(
            name: "AdSupport",
            dependencies: ["Data"],
            path: "Sources/AdSupport"),
        .target(
            name: "AppExtensions",
            dependencies: [],
            path: "Sources/AppExtensions"),
        .target(
            name: "Bluetooth",
            dependencies: ["Data"],
            path: "Sources/Bluetooth"),        

        .target(
            name: "Debug",
            dependencies: ["UI"],
            path: "Sources/Debug"),
        .target(
            name: "Experiences",
            dependencies: ["UI", "Rover"],
            path: "Sources/Experiences"),
        .target(
            name: "Location",
            dependencies: ["Data"],
            path: "Sources/Location"),
        .target(
            name: "Notifications",
            dependencies: ["UI"],
            path: "Sources/Notifications"),
        .target(
            name: "Telephony",
            dependencies: ["Data"],
            path: "Sources/Telephony"),
        .target(
            name: "Ticketmaster",
            dependencies: ["Data"],
            path: "Sources/Ticketmaster"),

        .testTarget(
            name: "RoverCampaignsTest",
            dependencies: [],
            path: "Tests"),
    ]
)
