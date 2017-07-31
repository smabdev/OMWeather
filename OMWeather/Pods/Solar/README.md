<div align="center">
<img src="./solar-logo.png" />
</div>

# Solar

[![Version](https://img.shields.io/cocoapods/v/Solar.svg?style=flat)](http://cocoapods.org/pods/Solar) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
 [![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/hyperium/hyper/master/LICENSE)

A Swift helper for generating Sunrise and Sunset times. Swift 3 compatible.

Solar uses an algorithm from the [United States Naval Observatory](http://williams.best.vwh.net/sunrise_sunset_algorithm.htm) for its calculations.

## Usage

Solar needs a date, a timezone and a location specified in latitude and longitude coordinates:

```swift
let solar = Solar(withTimeZone: NSTimeZone(name: "Europe/London"), 
		latitude: 51.528308, 
		longitude: -0.1340267)
let sunrise = solar.sunrise
let sunset = solar.sunset
```

When using Solar, you need to ensure that the timezone used is the timezone existing at the supplied latitude / longitude. 

### Timezones

Note that all dates are returned in UTC. This means that for timezones other than GMT, the time will appear off. Don't forget to convert your date into the appropriate timezone.

### Types of sunrise and sunset

- Official
- Civil
- Nautical
- Astromonical

## Convenience methods

Solar also comes packaged with some convenience methods:

```swift
let isDaytime = solar.isDaytime
let isNighttime = solar.isNighttime
```

## Installation

Solar is available through CocoaPods and Carthage. 

### Cocoapods

To install, simply add the following line to your podfile:

```ruby
pod "Solar"
```

Then run `pod install`

### Carthage

Add the `ceek/Solar` project to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile)

```ruby
github "ceeK/Solar"
```

Then run `carthage update`

## Todo:

- [ ] Documentation
- [ ] Unit tests

#### Future enhancements:

- [ ] Calculate more variables relating to solar activity, i.e. Moonrise, Moonset, Moon luminosity. 

# License 

The MIT License (MIT)

Copyright (c) 2016 Chris Howell

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
