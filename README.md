# VirtualTourist
This app allows users specify travel locations around the world, and create virtual photo albums for each location. The locations and photo albums are stored in iOS Core Data (using SQLite).

**Developed in Xcode 7 using Swift 2.**

**Technology Stack**

* Frontend Application
  * Swift/iOS
* Backend Application
  * Flickr
* Cocoa Frameworks
  * MapKit
  * Core Data

## Features and Functionality

* Drop pins anywhere on a world map.
* Tap the pin to see a photo gallery of images from that location.
* Images are fetched from Flickr using their public API.

![Virtual Tourist screenshot](/doc/vt1.png)
![Virtual Tourist screenshot](/doc/vt2.png)

## Key Files
* **Model**
  * Pin.swift:  Location (lat/long) information for a pin on the map
  * Photo.swift:  Photo image source URL and image file information
  * Flickr
    * Flickr-Constants.swift: API constants
    * Flickr.swift:  Networking methods
    * Flickr-Convenience.swift:  Networking convenience methods
    * ImageCache.swift:  Class for caching images from Flickr for Photo model
* **Controller**
  * PinDropViewController.swift:  Map view where users can drop pins
  * PhotoAlbumViewController.swift: Album view that displays a photo album when user taps on a pin
  * CoreDataStackManager.swift:  Core Data methods 
