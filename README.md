MessagePack.swift
=================

[![CI Status](http://img.shields.io/travis/a2/MessagePack.swift.svg?style=flat)](https://travis-ci.org/a2/MessagePack.swift)
[![Version](https://img.shields.io/cocoapods/v/MessagePack.swift.svg?style=flat)](http://cocoapods.org/pods/MessagePack.swift)
[![License](https://img.shields.io/cocoapods/l/MessagePack.swift.svg?style=flat)](http://cocoapods.org/pods/MessagePack.swift)
[![Platform](https://img.shields.io/cocoapods/p/MessagePack.swift.svg?style=flat)](http://cocoapods.org/pods/Oberholz)

A fast, zero-dependency MessagePack implementation written in Swift 3. Supports Apple platforms and Linux.

## Installation

### CococaPods

To use CocoaPods, add the following to your Podfile:

```ruby
pod 'MessagePack.swift', '~> 2.0.0'
```

### SPM (Swift Package Manager)

You can easily integrate MessagePack.swift in your app with SPM. Just add MessagePack.swift as a dependency:

```swift
import PackageDescription

let package = Package(
    name: "MyAwesomeApp",
    dependencies: [
        .Package(url: "https://github.com/a2/MessagePack.swift.git", majorVersion: 2, minor: 0),
    ]
)
```

## Version

2.0.0 supports Swift 3. Support for Swift 2 was dropped after [1.2.0](https://github.com/a2/MessagePack.swift/releases/tag/1.2.0).

## Xcode Support

As MessagePack.swift supports Swift Package Manager, you can develop the library in your text editor of choice. If you want to use Xcode, generate an Xcode projec with the following command:

```sh
$ swift package generate-xcodeproj
```

## Authors

Alexsander Akers, me@a2.io

## License

MessagePack.swift is available under the MIT license. See the LICENSE file for more info.
