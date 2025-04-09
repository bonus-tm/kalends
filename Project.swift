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
        )
    ]
) 