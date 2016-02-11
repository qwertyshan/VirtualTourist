//
//  Photo.swift
//  VirtualTourist
//
//  Created by Shantanu Rao on 2/10/16.
//  Copyright © 2016 Shantanu Rao. All rights reserved.
//

import CoreData
import CoreLocation
import UIKit

class Photo : NSManagedObject {
        
    struct Keys {
        static let Title = "title"
        static let ImagePath = "image_path"
    }
    
    @NSManaged var title: String
    @NSManaged var imagePath: String?
    @NSManaged var pin: Pin?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // Dictionary
        title = dictionary[Keys.Title] as! String
        imagePath = dictionary[Keys.ImagePath] as? String
        
    }
    
    var image: UIImage? {
        
        get {
            return Flickr.Caches.imageCache.imageWithIdentifier(imagePath)
        }
        
        set {
            Flickr.Caches.imageCache.storeImage(newValue, withIdentifier: imagePath!)
        }
    }
}
