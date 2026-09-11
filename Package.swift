// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Pam Workout",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        // An xtool project should contain exactly one library product,
        // representing the main app.
        .library(
            name: "PamWorkout",
            targets: ["PamWorkout"]
        ),
    ],
    targets: [
        .target(
            name: "PamWorkout",
            dependencies: ["Presentation", "Data"]
        ),
        .target(
            name: "Presentation",
            dependencies: ["Domain", "Core"]
        ),
        .target(
            name: "Data",
            dependencies: ["Domain", "Core"]
        ),
        .target(
            name: "Domain"
        ),
        .target(
            name: "Core",
            resources: [
                .process("DesignSystem/Colors.xcassets"),
                .process("Localization/Localizable.xcstrings")
            ]
        )
    ]
)
