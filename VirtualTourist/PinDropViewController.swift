//
//  PinDropViewController.swift
//  VirtualTourist
//
//  Created by Shantanu Rao on 2/11/16.
//  Copyright © 2016 Shantanu Rao. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PinDropViewController : UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    enum EditState {
        case Delete
        case Normal
    }
    
    var annotation = MKPointAnnotation()
    
    var editState: EditState = .Normal
    
    @IBOutlet var map: MKMapView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        
        let uitaphold = UILongPressGestureRecognizer(target: self, action: "addAnnotation:")
        uitaphold.minimumPressDuration = 1.0
        
        map.addGestureRecognizer(uitaphold)
        
        map.delegate = self
        fetchedResultsController.delegate = self
        
        map.addAnnotations(fetchAllPins())
    }
    
    // MARK: - Core Data Convenience. This will be useful for fetching. And for adding and saving objects as well.
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "longitude", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        return fetchedResultsController
        
    }()
    
    // MARK: - IBActions
    
    // Edit map
    @IBAction func editMapViewOnTouchUp(sender: AnyObject) {
        switch editState {
        case .Normal:
            editState = .Delete
            editButton.tintColor = UIColor.redColor()
            print("editMapViewOnTouchUp: Switched to Delete state")
        case .Delete:
            editState = .Normal
            editButton.tintColor = UIColor(red:0, green:0.569, blue:1, alpha:1)
            print("editMapViewOnTouchUp: Switched to Normal state")
        }
    }
    
    // MARK: Map view delegate methods
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = map.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            //pinView?.draggable = true
            pinView!.pinTintColor = UIColor.redColor()
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        // Check editState
        switch editState {
        // if .Normal, transition to PhotoAlbumView
        case .Normal:
            let controller = storyboard!.instantiateViewControllerWithIdentifier("PhotoAlbumViewController") as! PhotoAlbumViewController
            controller.pin = findPinWithLocation(view.annotation!.coordinate)
            map.deselectAnnotation(view.annotation, animated: false)
            self.navigationController!.pushViewController(controller, animated: true)
        // if .Delete (edit mode), delete pin
        case .Delete:
            print("Deleting pin with coordinates: \(view.annotation!.coordinate)")
            sharedContext.deleteObject(findPinWithLocation(view.annotation!.coordinate))
            saveContext()
            map.removeAnnotation(view.annotation!)
        }
    }
    
    // MARK: Helper methods
    
    func addAnnotation(gestureRecognizer:UILongPressGestureRecognizer){
        
        let touchPoint = gestureRecognizer.locationInView(map)
        let newCoordinates = map.convertPoint(touchPoint, toCoordinateFromView: map)
        
        switch gestureRecognizer.state{
        case .Began:
            print("Began gesture")
            let annotation = MKPointAnnotation()
            self.annotation = annotation
            dispatch_async(dispatch_get_main_queue(), {
                self.annotation.coordinate = newCoordinates
                self.map.addAnnotation(self.annotation)
            })
            
        case .Changed:
            print("Changed gesture")
            dispatch_async(dispatch_get_main_queue(), {
                self.annotation.coordinate = newCoordinates
            })
            
        case .Ended:
            print("Ended gesture")
            dispatch_async(dispatch_get_main_queue(), {
                self.annotation.coordinate = newCoordinates
            })
            let pin = Pin(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude, context: sharedContext)
            saveContext()
            print("Pin saved with latitude: \(pin.latitude) and longitude: \(pin.longitude)")
            preloadCollection(pin)
            
        default: break
        }
    }
    
    func fetchAllPins() -> [Pin] {
        
        // Create the Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        // Execute the Fetch Request
        do {
            return try sharedContext.executeFetchRequest(fetchRequest) as! [Pin]
        } catch _ {
            return [Pin]()
        }
    }
    
    func findPinWithLocation(location: CLLocationCoordinate2D) -> Pin {
        
        let pins: [Pin] = fetchAllPins()
        
        for pin in pins {
            if (pin.latitude == location.latitude) && (pin.longitude == location.longitude) {
                return pin
            }
        }
        return Pin()
    }
    
    func preloadCollection(pin: Pin) {
        
        // Get images from Flickr client
        Flickr.sharedInstance().getImagesFromFlickrByBbox(pin.latitude, longitude: pin.longitude) { data, error in
            
            // If error, show error label
            guard (error == nil) else {
                print("PhotoAlbumViewController -> There was an error with the parsed response: \(error)")
                return
            }
            
            // Parse returned photo array and add photos to model
            for dictionary in data as! [[String:AnyObject]] {
                let photo = Photo(dictionary: dictionary, context: self.sharedContext)
                photo.pin = pin
                self.saveContext()
                print("loadNewCollection: adding \(photo)")
                
                // Start the task that will eventually download the image
                let task = Flickr.sharedInstance().getFlickrImage(photo.imagePath!) { imageData, error in
                    if let error = error {
                        print("Image download error: \(error.localizedDescription)")
                    }
                    if let data = imageData {
                        print("Image download successful")
                        // Create the image
                        let photoImage = UIImage(data: data)!
                        // Update the model, so that the information gets cached
                        photo.image = photoImage
                        self.saveContext()
                    }
                }
                task.resume()
            }
        }
    }
    
    // MARK: - Save Managed Object Context helper
    func saveContext() {
        dispatch_async(dispatch_get_main_queue()) {
            _ = try? self.sharedContext.save()
        }
    }
}
