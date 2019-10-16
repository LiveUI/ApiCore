// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "ApiCore",
    products: [
        .library(name: "ApiCore", targets: ["ApiCore"]),
        .library(name: "FileCore", targets: ["FileCore"]),
        .library(name: "ImageCore", targets: ["ImageCore"]),
        .library(name: "ResourceCache", targets: ["ResourceCache"]),
//        .library(name: "ApiCoreTestTools", targets: ["ApiCoreTestTools"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0-alpha.3"),
        .package(url: "https://github.com/vapor/fluent.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor/jwt.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0"),
        .package(url: "https://github.com/twostraws/SwiftGD.git", .upToNextMinor(from: "2.3.0")),
        .package(url: "https://github.com/LiveUI/S3.git", from: "3.0.0"),
        .package(url: "https://github.com/LiveUI/MailCore.git", .branch("4")),
//        .package(url: "https://github.com/LiveUI/ErrorsCore.git", from: "0.1.0"),
        .package(url: "https://github.com/vapor-community/Imperial.git", from: "0.12.0")
    ],
    targets: [
        .target(
            name: "ApiCoreApp",
            dependencies: [
                "Vapor",
                "ApiCore"
            ]
        ),
        .target(
            name: "ResourceCache",
            dependencies: [
                "Vapor"
            ]
        ),
        .target(name: "ApiCoreRun", dependencies: [
            "ApiCoreApp"
            ]
        ),
        .target(name: "ApiCore", dependencies: [
            "Vapor",
            "Fluent",
            "Crypto",
            "Random",
            "FluentPostgreSQL",
            "JWT",
            "MailCore",
            "Leaf",
            "FileCore",
            "ImageCore",
            "Imperial",
            "ResourceCache"
            ]
        ),
        .target(name: "FileCore", dependencies: [
            "Vapor",
            "ErrorsCore",
            "S3"
            ]
        ),
        .target(name: "ImageCore", dependencies: [
            "Vapor",
            "SwiftGD",
            "COperatingSystem"
            ]
        ),
//        .target(
//            name: "ApiCoreTestTools",
//            dependencies: [
//                "Vapor",
//                "ApiCore",
//                "MailCoreTestTools"
//            ]
//        ),
//        .testTarget(name: "ApiCoreTests", dependencies: [
//            "Vapor",
//            "ErrorsCore",
//            "ApiCore",
//            "MailCore",
//            "ApiCoreTestTools",
//            "MailCoreTestTools"
//            ]
//        )
    ]
)
