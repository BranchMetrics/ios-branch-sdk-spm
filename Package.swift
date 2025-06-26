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
                url: "BranchSDK.xcframework"
            )
            
        ]
)

