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
    
    init(title: String, imagePath: String, context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // Entry
        self.title = title
        self.imagePath = imagePath
        
    }
    
    var image: UIImage? {
        
        // Getting and setting filename as URL's last component
        get {
            let url = NSURL(fileURLWithPath: imagePath!)
            let fileName = url.lastPathComponent
            return Flickr.Caches.imageCache.imageWithIdentifier(fileName!)
        }
        
        set {
            let url = NSURL(fileURLWithPath: imagePath!)
            let fileName = url.lastPathComponent
            Flickr.Caches.imageCache.storeImage(newValue, withIdentifier: fileName!)
        }
    }
    
    override func prepareForDeletion() {
        
        //Delete the associated image file when the Photo managed object is deleted.
        if let imagePath = imagePath {
            
            let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
            let pathArray = [dirPath, NSURL(fileURLWithPath: imagePath).lastPathComponent!]
            let fileURL = NSURL.fileURLWithPathComponents(pathArray)!
            
            do {
                try NSFileManager.defaultManager().removeItemAtURL(fileURL)
                print("Photo.image deleted successfully: \(pathArray)")
            } catch {
                print("Photo.image delete failed with error: \(error)")
            }
        }
    }
}
