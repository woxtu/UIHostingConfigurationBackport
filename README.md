# UIHostingConfigurationBackport

[![Swift Package Manager](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg?style=flat-square)](https://github.com/apple/swift-package-manager)

A backport of [`UIHostingConfiguration`](https://developer.apple.com/documentation/SwiftUI/UIHostingConfiguration) for iOS 14.0+.

```swift
import UIHostingConfigurationBackport

cell.contentConfiguration = UIHostingConfigurationBackport {
    HStack {
        Image(systemName: "star").foregroundStyle(.purple)
        Text("Favorites")
        Spacer()
    }
}
```

## Installation

### Swift Package Manager

```swift
.package(url: "https://github.com/woxtu/UIHostingConfigurationBackport.git", from: "0.1.0")
```

## License

Licensed under the MIT license.
