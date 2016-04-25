# NataliaClient

[![CI Status](http://img.shields.io/travis/Tyler Nappy/NataliaClient.svg?style=flat)](https://travis-ci.org/Tyler Nappy/NataliaClient)
[![Version](https://img.shields.io/cocoapods/v/NataliaClient.svg?style=flat)](http://cocoapods.org/pods/NataliaClient)
[![License](https://img.shields.io/cocoapods/l/NataliaClient.svg?style=flat)](http://cocoapods.org/pods/NataliaClient)
[![Platform](https://img.shields.io/cocoapods/p/NataliaClient.svg?style=flat)](http://cocoapods.org/pods/NataliaClient)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

NataliaClient is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "NataliaClient"
```

## Include it
```swift
let nataliaClient = NataliaClient(serviceUUID: "SERVICE_UUID")
```
Where you replace the 'SERVICE_UUID' with your devices service UUID.

## Setup
```swift
nataliaClient.setup()
```
This discovers your device and performs the proper setup for the device to turn LEDs on and off.

### Toggle LEDs
Takes 3 parameters, in this order:
* LED number (*required*)
  * Values accepted `1`, `2`, `3`, `4`, or `5`
* Toggle value (*required*)
  * Values accepted `'on'` or `'off'`
* Callback function (*optional*)

#### Turn on an LED
```swift
nataliaClient.toggleLED(1, state: "on")
```
#### Turn off an LED
```swift
nataliaClient.toggleLED(1, state: "off")
```

## Author

Tyler Nappy, tylernappy@gmail.com

## License

NataliaClient is available under the MIT license. See the LICENSE file for more info.
