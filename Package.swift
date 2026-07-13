// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "PullupBar",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "PullupBar",
            path: "Sources/PullupBar"
        ),
        .testTarget(
            name: "PullupBarTests",
            dependencies: ["PullupBar"],
            path: "Tests/PullupBarTests"
        )
    ]
)
