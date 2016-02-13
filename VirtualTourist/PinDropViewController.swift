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
    }
    
    // Remove pins
    @IBAction func removePinsOnTouchUp(sender: AnyObject) {
        
        // Remove existing annotations
        
    }
    
    // MARK: Helper methods
    
    func addAnnotation(gestureRecognizer:UIGestureRecognizer){
        let touchPoint = gestureRecognizer.locationInView(map)
        let newCoordinates = map.convertPoint(touchPoint, toCoordinateFromView: map)
        //let annotation = MKPointAnnotation()
        
        if UIGestureRecognizerState.Began == gestureRecognizer.state {
            let pin = Pin(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude, context: sharedContext)
            map.addAnnotation(pin)
            CoreDataStackManager.sharedInstance().saveContext()
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
    
    // MARK: Map view delegate methods
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = map.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.draggable = true
            pinView!.pinTintColor = UIColor.redColor()
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        let controller = storyboard!.instantiateViewControllerWithIdentifier("PhotoAlbumViewController") as! PhotoAlbumViewController
        /*
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        let predicate1 = NSPredicate(format: "latitude == %@", view.annotation!.coordinate.latitude)
        let predicate2 = NSPredicate(format: "longitude == %@", view.annotation!.coordinate.longitude)
        let predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [predicate1, predicate2])
        fetchRequest.predicate = predicate

        if let pins = try? sharedContext.executeFetchRequest(fetchRequest) as! [Pin] {
            print(pins.enumerate())
            controller.pin = pins[0]
            self.navigationController!.pushViewController(controller, animated: true)
        }
        */
        controller.pin = findPinWithLocation(view.annotation!.coordinate)

        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        
        switch (newState) {
        case .Starting:
            
            if let startPin = view.annotation as? Pin {
                sharedContext.deleteObject(startPin)
                CoreDataStackManager.sharedInstance().saveContext()
            }
            
        case .Ending, .Canceling:
            
            if let endPin = view.annotation as? Pin {
                endPin.longitude = (view.annotation?.coordinate.longitude)!
                endPin.latitude = (view.annotation?.coordinate.latitude)!
                CoreDataStackManager.sharedInstance().saveContext()
            }
        default: break
        }
    }
    
    // MARK: NSFetchResultsController delegate methods
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
    }
    
    func controller(controller: NSFetchedResultsController,
        didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
        atIndex sectionIndex: Int,
        forChangeType type: NSFetchedResultsChangeType) {
    }
    
    func controller(controller: NSFetchedResultsController,
        didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?) {
            
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
    }

    
}
