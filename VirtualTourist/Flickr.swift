//
//  Flickr.swift
//  VirtualTourist
//
//  Created by Shantanu Rao on 2/10/16.
//  Copyright © 2016 Shantanu Rao. All rights reserved.
//

import Foundation
import UIKit

class Flickr : NSObject {
    
    typealias CompletionHander = (result: AnyObject!, error: NSError?) -> Void
    
    var session: NSURLSession
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // MARK: - All purpose task method for data
    
    func taskWithParameters(parameters: [String : AnyObject], completionHandler: CompletionHander) -> NSURLSessionDataTask {
        
        var mutableParameters = parameters
        
        // Add in the API Key
        mutableParameters[Keys.ApiKey] = Constants.API_KEY
        
        let urlString = Constants.BASE_URL_SSL + Flickr.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        print(url)
        
        let task = session.dataTaskWithRequest(request) {data, response, error in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            /* Parse the data! */
            print("taskWithParameters's completionHandler is invoked.")
            Flickr.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            
        }
        
        task.resume()
        
        return task
    }
    
    
    
    
    // MARK: - Helpers
    
    // Parsing the JSON
    
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: CompletionHander) {
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject?
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        } catch let error as NSError {
            parsingError = error
            parsedResult = nil
        }
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            print("parseJSONWithCompletionHandler is invoked.")
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    // URL Encoding a dictionary into a parameter string
    
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            // make sure that it is a string value
            let stringValue = "\(value)"
            
            // Escape it
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            // Append it
            
            if let unwrappedEscapedValue = escapedValue {
                urlVars += [key + "=" + "\(unwrappedEscapedValue)"]
            } else {
                print("Warning: trouble escaping string \"\(stringValue)\"")
            }
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> Flickr {
        
        struct Singleton {
            static var sharedInstance = Flickr()
        }
        
        return Singleton.sharedInstance
    }
    
    // MARK: - Shared Image Cache
    
    struct Caches {
        static let imageCache = ImageCache()
    }
    
}
