# APCoreData

[![Version](https://img.shields.io/cocoapods/v/APCoreData.svg?style=flat)](http://cocoadocs.org/docsets/APCoreData)
[![License](https://img.shields.io/cocoapods/l/APCoreData.svg?style=flat)](http://cocoadocs.org/docsets/APCoreData)
[![Platform](https://img.shields.io/cocoapods/p/APCoreData.svg?style=flat)](http://cocoadocs.org/docsets/APCoreData)

APCoreData is simple and clear `CoreData` stack and useful categories, that partially based on https://github.com/soffes/ssdatakit

Stack is configured with two `NSManagedObjectContext` objects on main and backgorund threads with merge changes strategy via notification (learn more: http://floriankugler.com/blog/2013/5/11/backstage-with-nested-managed-object-contexts).

## Usage

```obj-c
// init CoreData stack in `-application:didFinishLaunchingWithOptions:`
//
[NSManagedObjectContext ap_managedObjectContext];
```
## Installation

APCoreData is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "APCoreData"

## Author

Andrew Podkovyrin, podkovyrin@gmail.com

## License

APCoreData is available under the MIT license. See the LICENSE file for more info.

