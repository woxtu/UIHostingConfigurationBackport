// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "UIHostingConfigurationBackport",
  products: [
    .library(name: "UIHostingConfigurationBackport", targets: ["UIHostingConfigurationBackport"]),
  ],
  targets: [
    .target(name: "UIHostingConfigurationBackport"),
  ]
)
