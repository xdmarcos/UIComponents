// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "UIComponents",
  platforms: [.iOS(.v11)],
  products: [
    .library(
      name: "UIComponents",
      targets: ["UIComponents"]
    ),
  ],
  targets: [
    .target(name: "UIComponents", path: "Sources"),
  ],
  swiftLanguageVersions: [.v5]
)
