// swift-tools-version: 6.0

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "Stitch",
    platforms: [
        .iOS(.v13),
        .macOS(.v11),
    ],
    products: [
        .library(
            name: "Stitch",
            targets: ["Stitch"]
        ),
        .executable(
            name: "StitchClient",
            targets: ["StitchClient"]
        ),
    ],
    dependencies: [
        // Depend on the latest Swift 5.9 prerelease of SwiftSyntax
        .package(url: "https://github.com/swiftlang/swift-syntax.git", "600.0.1" ..< "604.0.0"),
    ],
    targets: [
        .macro(
            name: "StitchMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "Stitch",
            dependencies: ["StitchMacros"]
        ),
        .executableTarget(name: "StitchClient", dependencies: ["Stitch"]),
        .testTarget(
            name: "StitchMacroTests",
            dependencies: [
                "Stitch",
                "StitchMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
        .testTarget(
            name: "StitchTests",
            dependencies: ["Stitch"]
        ),
    ]
)
