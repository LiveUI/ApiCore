// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "ApiCore",
    products: [
        .library(name: "ApiCore", targets: ["ApiCore"]),
        .library(name: "FileCore", targets: ["FileCore"]),
        .library(name: "ImageCore", targets: ["ImageCore"]),
        .library(name: "ApiCoreTestTools", targets: ["ApiCoreTestTools"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/core.git", from: "3.4.1"),
        .package(url: "https://github.com/vapor/crypto.git", from: "3.2.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0-rc.4"),
        .package(url: "https://github.com/vapor/jwt.git", from: "3.0.0-rc.2"),
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0-rc.2"),
        .package(url: "https://github.com/twostraws/SwiftGD.git", from: "2.0.0"),
        .package(url: "https://github.com/LiveUI/S3.git", .branch("master")),
        .package(url: "https://github.com/LiveUI/MailCore.git", .branch("master")),
        .package(url: "https://github.com/LiveUI/ErrorsCore.git", .branch("master")),
        .package(url: "https://github.com/LiveUI/VaporTestTools.git", from: "0.1.5"),
        .package(url: "https://github.com/LiveUI/FluentTestTools.git", .branch("master"))
    ],
    targets: [
        .target(
            name: "ApiCoreApp",
            dependencies: [
                "Vapor",
                "ApiCore",
                "GithubLogin"
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
            "ErrorsCore",
            "JWT",
            "MailCore",
            "Leaf",
            "FileCore",
            "ImageCore"
            ]
        ),
        .target(name: "FileCore", dependencies: [
            "Vapor",
            "ErrorsCore",
            "S3"
            ]
        ),
        .target(name: "GithubLogin", dependencies: [
            "Vapor"
            ]
        ),
        .target(name: "ImageCore", dependencies: [
            "Vapor",
            "ErrorsCore",
            "SwiftGD",
            "COperatingSystem"
            ]
        ),
        .target(
            name: "ApiCoreTestTools",
            dependencies: [
                "Vapor",
                "ApiCore",
                "VaporTestTools",
                "FluentTestTools",
                "MailCoreTestTools"
            ]
        ),
        .testTarget(name: "ApiCoreTests", dependencies: [
            "Vapor",
            "ErrorsCore",
            "ApiCore",
            "MailCore",
            "VaporTestTools",
            "FluentTestTools",
            "ApiCoreTestTools",
            "MailCoreTestTools"
            ]
        )
    ]
)
