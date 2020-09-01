// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Sensor",
    platforms: [
       .macOS(.v10_13),
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Sensor",
            targets: ["Sensor"]),
        .library(
            name: "SensorTest",
            targets: ["SensorTest"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "5.1.1"),
        .package(url: "https://github.com/NoTests/RxFeedback.swift.git", from: "3.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.7.2"),
    ],
    targets: [
        .target(
            name: "Sensor",
            dependencies: ["RxSwift", "RxCocoa", "RxFeedback"],
            path: "Sensor/Sources"),
        .testTarget(
            name: "SensorUnitTests",
            dependencies: ["Sensor", "SensorTest", "RxSwift", "RxCocoa"],
            path: "Sensor/UnitTests"),
        .target(
            name: "SensorTest",
            dependencies: ["RxCocoa", "RxTest"],
            path: "SensorTest/Sources"),
        .testTarget(
            name: "SensorTestUnitTests",
            dependencies: ["SensorTest", "SnapshotTesting"],
            path: "SensorTest/UnitTests"),
    ]
)
