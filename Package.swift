// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Stitch",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "Stitch",
            targets: ["Stitch"]
        ),
    ],
    dependencies: [
        
    ],
    targets: [
        .target(
            name: "Stitch",
            dependencies: []
        ),
        .testTarget(
            name: "StitchTests",
            dependencies: ["Stitch"]
        ),
    ]
)
