CMMapLauncher
=============
> The orginal code was produced by [Citymapper](https://github.com/citymapper/CMMapLauncher) but this fork is an update on [dpa99c's fork](https://github.com/dpa99c/CMMapLauncher) updating the code base post iOS 10 & adding Cocoapod support with UI helpers

CMMapLauncher is a mini-library for iOS that makes it quick and easy to show directions in various mapping applications.  To use it, just add `CMMapLauncher.h` and `CMMapLauncher.m` to your project.

To check whether one of the supported mapping apps is present on the user's device:

    BOOL installed = [CMMapLauncher isMapAppInstalled:CMMapAppCitymapper];
    
Then, to launch into directions in that app:

```
    CLLocationCoordinate2D bigBen = CLLocationCoordinate2DMake(51.500755, -0.124626);
    [CMMapLauncher launchApp:CMMapAppCitymapper
             forDirectionsTo:[CMMapPoint mapPointWithName:@"Big Ben" coordinate:bigBen]]
                     handler:NULL;
```

```swift
let bigBen = CLLocationCoordinate2DMake(latitude: 51.500755, longitude: -0.124626)
MapLauncher.launch(.citymapper, to: MapPoint(name: "Big Ben", coordinate: bigBen))
```

Enable debug logging to log the launch URI/parameters:

    [CMMapLauncher enableDebugLogging];

CMMapLauncher currently knows how to show directions in the following mapping apps:

* Apple Maps &mdash; `CMMapAppAppleMaps`
* Citymapper &mdash; `CMMapAppCitymapper`
* Google Maps &mdash; `CMMapAppGoogleMaps`
* Navigon &mdash; `CMMapAppNavigon`
* The Transit App &mdash; `CMMapAppTheTransitApp`
* Waze &mdash; `CMMapAppWaze`
* Yandex Navigator &mdash; `CMMapAppYandex`
* Uber &mdash; `CMMapAppUber`
* TomTom &mdash; `CMMapAppTomTom`
* Sygic &mdash; `CMMapAppSygic`
* HERE Maps &mdash; `CMMapAppHereMaps`

If you know of other direction-providing apps that expose a URL scheme for launching from other apps, this project wants to incorporate them!  Pull requests and issues providing URL schemes are encouraged.

CMMapLauncher was originally created by [Citymapper](http://citymapper.com), but is released under the MIT License for the benefit of the iOS developer community.
