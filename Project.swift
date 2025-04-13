import ProjectDescription

let project = Project(
    name: "Kalends",
    organizationName: "Kalends",
    targets: [
        Target(
            name: "Kalends",
            platform: .macOS,
            product: .app,
            bundleId: "com.kalends.app",
            infoPlist: "Kalends/Info.plist",
            sources: ["Kalends/**"],
            resources: ["Kalends/Resources/**"],
            dependencies: []
        ),
        Target(
            name: "KalendsTests",
            platform: .macOS,
            product: .unitTests,
            bundleId: "com.kalends.tests",
            infoPlist: "KalendsTests/Info.plist",
            sources: ["KalendsTests/**"],
            dependencies: [
                .target(name: "Kalends")
            ]
        )
    ]
) 