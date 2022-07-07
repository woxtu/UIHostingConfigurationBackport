// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "UIHostingConfigurationBackport",
  platforms: [
    .iOS(.v14),
    .tvOS(.v14),
  ],
  products: [
    .library(name: "UIHostingConfigurationBackport", targets: ["UIHostingConfigurationBackport"]),
  ],
  targets: [
    .target(name: "UIHostingConfigurationBackport"),
  ]
)
