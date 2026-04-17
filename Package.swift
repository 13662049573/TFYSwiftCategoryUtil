// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "TFYSwiftCategoryUtil",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "TFYSwiftCategoryUtil",
            targets: ["TFYSwiftCategoryUtil"]
        )
    ],
    targets: [
        .target(
            name: "TFYSwiftCategoryUtil",
            path: "TFYSwiftCategoryUtil/TFYSwiftCategoryUtil"
        ),
        .testTarget(
            name: "TFYSwiftCategoryUtilPackageTests",
            dependencies: ["TFYSwiftCategoryUtil"],
            path: "TFYSwiftCategoryUtilTests",
            exclude: ["Info.plist"],
            sources: ["TFYSwiftCategoryUtilTests.swift"]
        )
    ],
    swiftLanguageVersions: [.v5]
)
