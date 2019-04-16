// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "RxDux",
    products: [
        .library(
            name: "RxDux",
            targets: ["RxDux"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/ReactiveX/RxSwift.git", "4.0.0" ..< "5.0.0")
    ],
    targets: [
        .target(
            name: "RxDux",
            dependencies: ["RxSwift", "RxCocoa"]),
        .testTarget(
            name: "RxDuxTests",
            dependencies: ["RxDux"]),
    ]
)
