// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JeffKit",
    platforms: [
        .iOS(.v17)    // Set minimum iOS version to 16.0
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "JeffKit",
            targets: ["JeffKit"]),
    ],
    dependencies: [
            // Add dependencies here
//            .package(url: "https://github.com/nonstrict-hq/CloudStorage.git", exact: "0.6.0")
            // Or specify version ranges
            .package(url: "https://github.com/airbnb/lottie-ios.git", "4.0.0"..<"5.0.0"),
            .package(url: "https://github.com/wishkit/wishkit-ios.git", "4.0.0"..<"5.0.0"),
//            // Or exact version
//            .package(url: "https://github.com/org/package.git", exact: "1.0.0"),
//            // Or branch
            .package(url: "https://github.com/mixpanel/mixpanel-swift", branch: "master")
    ],
    targets: [
        .target(
            name: "JeffKit",
            dependencies: [
                .product(name: "Mixpanel", package: "mixpanel-swift"),
                .product(name: "WishKit", package: "wishkit-ios"),
                .product(name: "Lottie", package: "lottie-ios")
            ]
        ),
        .testTarget(
            name: "JeffKitTests",
            dependencies: ["JeffKit"]
        ),
    ]
)
