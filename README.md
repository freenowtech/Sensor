![Sensor](Docs/images/Sensor.png)

# Sensor
![Swift 5](https://img.shields.io/badge/Swift-5-orange.svg)
![Cocoapods compatible](https://img.shields.io/cocoapods/v/Sensor.svg)
![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)

Nowadays, mobile applications become increasingly powerful and complex, rich of features that try to improve the user's experience. But power is nothing without control: the more powerful (and complex) the app is, the highest the chance it can end up in an inconsistent state.

The good news is our **Sensor Architecture**: an elegant and a good way to organise your code when working with complex applications.
With the ability to define all the possible states, of each feature of a mobile application, the chances to end up in an inconsistent state are most unlikely. Thanks to the concept of the State Machine and its deterministic behaviour, we can be sure that all the transitions from a state to another state are regulated by a finite set of events that can happen.

The **Sensor** framework comes with batteries included so you can start writing safe apps straight away.

The **SensorTest** framework includes some goodies to help you write unit tests in a breeze.

## Learn more
**[Read the docs](Docs/sensor.md)**

[Video with a presentation of this architecture](https://www.youtube.com/watch?v=Dp2LQo2DOcg&t=15s)

[Presentation used on the video](https://github.com/freenowtech/Sensor/blob/master/CodingTestableAppsOnSteroids.pdf)

## Setup
### Cocoapods
To use the **Sensor** framework, add the following line to the target of your app on your Podfile:

`pod 'Sensor', '0.1.1'`

In your app, add the following import:

`import Sensor`

To use the **SensorTest** framework, add the following line to the test target on your Podfile:

`pod 'SensorTest', '0.1.1'`

In your tests, add the following import:

`import SensorTest`

### Swift Package Manager
Add the following line to your package dependencies:

`.package(url: "https://github.com/freenowtech/Sensor.git", from: "0.1.1"),`

Add `Sensor` to your main target dependencies. Add `SensorTest` to your test target dependencies.

The minimum macOS version is 10.13.

Example `Package.swift` file:
```swift
// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Package",
    platforms: [
       .macOS(.v10_13),
    ],
    dependencies: [
        .package(url: "https://github.com/freenowtech/Sensor.git", from: "0.1.1"),
    ],
    targets: [
        .target(
            name: "Target",
            dependencies: ["Sensor"]),
        .testTarget(
            name: "TestTarget",
            dependencies: ["Target", "SensorTest"]),
    ]
)
```

## Contributors
* Stefan Bieschewski
* David Cortés [<img src="Docs/images/SocialIcons/GitHub-Mark-32px.png" width="15" height="15">](https://github.com/davebcn87)
* Fabio Cuomo
* Mounir Dellagi
* Lluís Gómez [<img src="Docs/images/SocialIcons/GitHub-Mark-32px.png" width="15" height="15">](https://github.com/lluisgh28)
* Carlos Nuñez
* Ferran Pujol [<img src="Docs/images/SocialIcons/GitHub-Mark-32px.png" width="15" height="15">](https://github.com/ferranpujolcamins) [<img src="Docs/images/SocialIcons/Twitter_Social_Icon_Circle_Color.png" width="15" height="15">](https://twitter.com/ferranpujolca)
* Adrian Zdanowicz
