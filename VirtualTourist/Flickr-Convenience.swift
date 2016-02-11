//
//  Flickr-Convenience.swift
//  VirtualTourist
//
//  Created by Shantanu Rao on 2/10/16.
//  Copyright © 2016 Shantanu Rao. All rights reserved.
//

import Foundation

extension Flickr {
    
    // MARK: - Convenience methods
    
    func getImagesFromFlickrByBbox(latitude: Double, longitude: Double) {
        
        let methodArguments = [
            Keys.Method:         Constants.METHOD_NAME,
            Keys.Bbox:           createBoundingBoxString(latitude, longitude: longitude),
            Keys.SafeSearch:     Constants.SAFE_SEARCH,
            Keys.Extras:         Constants.EXTRAS,
            Keys.Format:         Constants.DATA_FORMAT,
            Keys.NoJsonCallBack: Constants.NO_JSON_CALLBACK,
            Keys.Accuracy:       Constants.ACCURACY
        ]
        
        let task = taskWithParameters(methodArguments as! [String : AnyObject]) {data, error in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with the parsed response: \(error)")
                return
            }
            
            /* GUARD: Did Flickr return an error? */
            guard let stat = data["stat"] as? String where stat == "ok" else {
                print("Flickr API returned an error. See error code and message in \(data)")
                return
            }
            
            /* 1 - Get the photos dictionary */
            /* GUARD: Is "photos" key in our result? */
            guard let photosDictionary = data["photos"] as? NSDictionary else {
                print("Cannot find keys 'photos' in \(data)")
                return
            }
            
            /* 2 - Determine the total number of photos */
            /* GUARD: Is the "total" key in photosDictionary? */
            guard let totalPhotos = (photosDictionary["total"] as? NSString)?.integerValue else {
                print("Cannot find key 'total' in \(photosDictionary)")
                return
            }
            
            /* 3 - If photos are returned, let's a few */
            if totalPhotos > 0 {
                
                /* GUARD: Is the "photo" key in photosDictionary? */
                guard let photosArray = photosDictionary["photo"] as? [[String: AnyObject]] else {
                    print("Cannot find key 'photo' in \(photosDictionary)")
                    return
                }
                
                /* 4 - Get a random index, and pick a random photo's dictionary */
                
                // Set array length to smaller of two values: photosArray.count or MaxPhotosToDisplay
                let arrayLength = min(photosArray.count, Config.MaxPhotosToDisplay)
                
                // Create an array of random photo indices
                let randomPhotoIndexArray = (1...arrayLength).map{_ in Int(arc4random_uniform(UInt32(photosArray.count)))}
                print("randomPhotoIndexArray: \(randomPhotoIndexArray)")
                
                // Build array of photoDictionary
                var photoDictionaryArray = [[String: AnyObject]]()
                
                for randomPhotoIndex in randomPhotoIndexArray {
                    photoDictionaryArray.append(photosArray[randomPhotoIndex] as [String: AnyObject])
                }
                
                // TODO: Add photos from the photo dictionary to the Photo model (instead of displaying on view)
                
                    /* 5 - Prepare the UI updates */
                    let photoTitle = photoDictionary["title"] as? String /* non-fatal */
                    
                    /* GUARD: Does our photo have a key for 'url_m'? */
                    guard let imageUrlString = photoDictionary["url_m"] as? String else {
                        print("Cannot find key 'url_m' in \(photoDictionary)")
                        return
                    }
                    
                    let imageURL = NSURL(string: imageUrlString)
                    
                    /* 6 - Update the UI on the main thread */
                    if let imageData = NSData(contentsOfURL: imageURL!) {
                        dispatch_async(dispatch_get_main_queue(), {
                           // self.defaultLabel.alpha = 0.0
                         //   self.photoImageView.image = UIImage(data: imageData)
                       //     self.photoTitleLabel.text = photoTitle ?? "(Untitled)"
                        })
                    } else {
                        print("Image does not exist at \(imageURL)")
                    }
                
            } else {
                dispatch_async(dispatch_get_main_queue(), {
             //       self.photoTitleLabel.text = "No Photos Found. Search Again."
               //     self.defaultLabel.alpha = 1.0
                 //   self.photoImageView.image = nil
                })
            }
        }
        
        task.resume()
    }
    
    func createBoundingBoxString(latitude: Double, longitude: Double) -> String {
        
        let bottom_left_lon = max(longitude - Constants.BOUNDING_BOX_HALF_WIDTH,  Constants.LON_MIN)
        let bottom_left_lat = max(latitude  - Constants.BOUNDING_BOX_HALF_HEIGHT, Constants.LAT_MIN)
        let top_right_lon   = min(longitude + Constants.BOUNDING_BOX_HALF_HEIGHT, Constants.LON_MAX)
        let top_right_lat   = min(latitude  + Constants.BOUNDING_BOX_HALF_HEIGHT, Constants.LAT_MAX)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
    
}
