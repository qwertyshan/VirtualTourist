//
//  TaskCancelingCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Shantanu Rao on 2/13/16.
//  Copyright © 2016 Shantanu Rao. All rights reserved.
//
//  Based on code by Udacity

import UIKit

class TaskCancelingCollectionViewCell : UICollectionViewCell {
    
    // The property uses a property observer. Any time its
    // value is set it canceles the previous NSURLSessionTask
    
    var imageName: String = ""
    
    var taskToCancelifCellIsReused: NSURLSessionTask? {
        
        didSet {
            if let taskToCancel = oldValue {
                taskToCancel.cancel()
            }
        }
    }
}

