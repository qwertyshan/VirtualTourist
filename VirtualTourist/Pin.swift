//
//  Pin.swift
//  VirtualTourist
//
//  Created by Shantanu Rao on 2/10/16.
//  Copyright © 2016 Shantanu Rao. All rights reserved.
//

import CoreData
import CoreLocation
import MapKit

class Pin : NSManagedObject, MKAnnotation {
    
    struct Keys {
        static let ID = "id"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let Photos = "photos"
    }
    
    // Promote from simple properties, to Core Data attributes
    @NSManaged var id: Int
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var photos: [Photo]
    
    // Standard Core Data init method
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    // Init from dictionary
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        if dictionary[Keys.ID] != nil {
            id = dictionary[Keys.ID] as! Int
        } else {
            id = Int(arc4random())
        }
        latitude = dictionary[Keys.Latitude] as! Double
        longitude = dictionary[Keys.Longitude] as! Double
    }
    
    // Init single pin
    init(latitude: Double, longitude: Double, id: Int?, context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        if id != nil {
            self.id = id!
        } else {
            self.id = Int(arc4random())
        }
        self.latitude = latitude
        self.longitude = longitude
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
}