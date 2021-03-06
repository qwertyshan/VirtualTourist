//
//  Flickr-Convenience.swift
//  VirtualTourist
//
//  Created by Shantanu Rao on 2/10/16.
//  Copyright © 2016 Shantanu Rao. All rights reserved.
//

import Foundation
import UIKit
import GameplayKit 

extension Flickr {
    
    // MARK: - Convenience methods
    
    func getImagesFromFlickrByBbox(latitude: Double, longitude: Double, completionHandler: CompletionHander) -> Void {
        
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
                
                /* 4 - Shuffle the array to pick random photos */
                
                let shuffledPhotosArray = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(photosArray)

                // Set array length to smaller of two values: photosArray.count or MaxPhotosToDisplay
                let arrayLength = min(photosArray.count, Config.MaxPhotosToDisplay)
                print("arrayLength: \(arrayLength)")
                
                // Build array of photoDictionary
                var photoDictionaryArray = [[String: AnyObject]]()
                var photo: [String:String]
                var insertImagePath: String
                var insertTitle: String
                
                for randomPhotoIndex in 0...(arrayLength-1) {
                    print(shuffledPhotosArray[randomPhotoIndex])
                    let imagePath: String? = shuffledPhotosArray[randomPhotoIndex]["url_m"] as! String?
                    print("imagePath: \(imagePath)")
                    if (imagePath != nil) && (imagePath != "") {
                        insertImagePath = imagePath!
                    } else {    // If no url_m is received, add nil string
                        insertImagePath = ""
                    }
                    let title: String? = shuffledPhotosArray[randomPhotoIndex]["title"] as! String?
                    print("title: \(title)")
                    if (imagePath != nil) && (imagePath != "") {
                        insertTitle = title!
                    } else {    // If no title is received, add nil string
                        insertTitle = ""
                    }
                    photo = [
                        Photo.Keys.Title: insertTitle,
                        Photo.Keys.ImagePath: insertImagePath
                    ]
                    // Append photo with randomPhotoIndex to our photoDictionaryArray
                    photoDictionaryArray.append(photo as [String:String])
                }
                
                print("photoDictionaryArray is built")
                completionHandler(result: photoDictionaryArray, error: nil)
            }
                
            else {
                print("photoDictionaryArray could NOT be built. No photos received.")
                let userInfo: [NSObject : AnyObject] = [NSLocalizedDescriptionKey :  NSLocalizedString("No Images", value: "No images received from Flickr.", comment: "")]
                completionHandler(result: nil, error: NSError(domain: "getImagesFromFlickrByBbox", code: 1, userInfo: userInfo))
            }
        }
        
        task.resume()
    }
    
    func getFlickrImage(imagePath: String, completionHandler: (imageData: NSData?, error: NSError?) -> Void) ->  NSURLSessionTask {
        
        let imageURL = NSURL(string: imagePath)
        
        let request = NSURLRequest(URL: imageURL!)
        
        print("getFlickrImage --> imagePath: \(imagePath)")
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if let error = downloadError {
                completionHandler(imageData: nil, error: error)
            } else {
                completionHandler(imageData: data, error: nil)
            }
        }
        
        task.resume()
        
        return task
    }
    
    func createBoundingBoxString(latitude: Double, longitude: Double) -> String {
        
        let bottom_left_lon = max(longitude - Constants.BOUNDING_BOX_HALF_WIDTH,  Constants.LON_MIN)
        let bottom_left_lat = max(latitude  - Constants.BOUNDING_BOX_HALF_HEIGHT, Constants.LAT_MIN)
        let top_right_lon   = min(longitude + Constants.BOUNDING_BOX_HALF_HEIGHT, Constants.LON_MAX)
        let top_right_lat   = min(latitude  + Constants.BOUNDING_BOX_HALF_HEIGHT, Constants.LAT_MAX)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
    
}
