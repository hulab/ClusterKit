// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "ClusterKit",
    platforms: [
        .macOS(.v10_15), .iOS(.v9), .tvOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "ClusterKit",
            targets: ["ClusterKit"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ClusterKit"
        ),
    ]
)
