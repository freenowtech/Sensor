// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GenerateDocsComponent",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        .package(url: "https://github.com/ferranpujolcamins/Interplate.git", .revision("4354f59cbf0790f4c1c95d4cb68941288ee64f2f")),
        .package(name: "Path.swift", url: "https://github.com/mxcl/Path.swift.git", from: "1.0.0"),
        .package(url: "https://github.com/JohnSundell/Ink.git", from: "0.5.0"),
        .package(name: "Bow", url: "https://github.com/bow-swift/bow.git", from: "0.8.0")
    ],
    targets: [
        .target(
            name: "GenerateDocsComponent",
            dependencies: ["GenerateDocsComponentLib"]),
        .target(
            name: "GenerateDocsComponentLib",
            dependencies: [
                "Interplate",
                "Ink",
                .product(name: "Bow", package: "Bow"),
                .product(name: "BowOptics", package: "Bow"),
                .product(name: "Path", package: "Path.swift")]),
        .testTarget(
            name: "GenerateDocsComponentLibTests",
            dependencies: [
                "GenerateDocsComponentLib",
                .product(name: "Bow", package: "Bow")
        ]),
    ]
)
