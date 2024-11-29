// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "TipJarViewController",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "TipJarViewController",
            targets: ["TipJarViewController"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/lionheart/QuickTableView.git", from: "5.0.0"),
        .package(url: "https://github.com/lionheart/SuperLayout.git", from: "4.0.0"),
        .package(url: "https://github.com/lionheart/LionheartExtensions.git", from: "6.0.0")
    ],
    targets: [
        .target(
            name: "TipJarViewController",
            dependencies: [
                .product(name: "QuickTableView", package: "QuickTableView"),
                .product(name: "SuperLayout", package: "SuperLayout"),
                .product(name: "LionheartExtensions", package: "LionheartExtensions")
            ],
            path: "TipJarViewController/Classes"
        ),
        .testTarget(
            name: "TipJarViewControllerTests",
            dependencies: ["TipJarViewController"]
        )
    ],
    swiftLanguageModes: [.v4]
)
