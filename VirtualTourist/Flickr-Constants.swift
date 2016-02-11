//
//  Flickr-Constants.swift
//  VirtualTourist
//
//  Created by Shantanu Rao on 2/10/16.
//  Copyright © 2016 Shantanu Rao. All rights reserved.
//

import Foundation

extension Flickr {
    
    struct Constants {
        static let API_KEY = "57a25f910fa4ad495f7b9e8f1fcd26ea"
        static let BASE_URL_SSL = "https://api.flickr.com/services/rest/"
        static let METHOD_NAME = "flickr.photos.search"
        static let EXTRAS = "url_m"
        static let SAFE_SEARCH = "1"
        static let DATA_FORMAT = "json"
        static let NO_JSON_CALLBACK = "1"
        static let BOUNDING_BOX_HALF_WIDTH = 1.0
        static let BOUNDING_BOX_HALF_HEIGHT = 1.0
        static let LAT_MIN = -90.0
        static let LAT_MAX = 90.0
        static let LON_MIN = -180.0
        static let LON_MAX = 180.0
        static let ACCURACY = 10
        static let PER_PAGE = 500
    }
    
    struct Keys {
        static let Method = "method"
        static let ApiKey = "api_key"
        static let Bbox = "bbox"
        static let SafeSearch = "safe_search"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJsonCallBack = "nojsoncallback"
        static let Accuracy = "accuracy"
        static let PerPage = "per_page"
    }
    
    struct Config {
        static let MaxPhotosToDisplay = 20
    }
    
}