//
//  Pin.swift
//  VirtualTourist
//
//  Created by Shantanu Rao on 2/10/16.
//  Copyright © 2016 Shantanu Rao. All rights reserved.
//

import CoreData
import CoreLocation

class Pin : NSManagedObject {
    
    struct Keys {
        static let ID = "id"
        static let Location = "location"
        static let Photos = "photos"
    }
    
    // Promote from simple properties, to Core Data attributes
    @NSManaged var id: NSNumber
    @NSManaged var location: CLLocationCoordinate2D
    @NSManaged var photos: [Photo]
    
    // Standard Core Data init method
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    // Init from dictionary
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        id = dictionary[Keys.ID] as! Int
        location = dictionary[Keys.Location] as! CLLocationCoordinate2D
    }
}