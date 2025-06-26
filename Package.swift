// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "ios-branch-deep-linking-attribution",
    platforms: [
            .iOS(.v13),
            .tvOS(.v13),
        ],
        products: [
            .library(
                name: "BranchSDK",
                targets: ["BranchSDKBinary"]
            ),
        ],
        targets: [
            .binaryTarget(
                name: "BranchSDKBinary",
                url: "https://github.com/NidhiDixit09/nidhidixit09.github.io/raw/refs/heads/main/Branch.zip",
                checksum: "0a64c78eee4a342b3f4b5bf7bc5cc1fa1e67054398cf5edab0331fc79698313f"
            )
            
        ]
)

