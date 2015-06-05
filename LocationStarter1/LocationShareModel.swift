//
//  LocationShareModel.swift
//  LocationStarter1
//
//  Created by S Venu Madhav Chitta on 6/4/15.
//  Copyright (c) 2015 S Venu Madhav Chitta. All rights reserved.
//

import Foundation
import UIKit

class LocationShareModel : NSObject {
    var timer : NSTimer?
    var bgTask : BackgroundTaskManager?
    var myLocationArray : NSMutableArray?
    func sharedModel()-> AnyObject {
        struct Static {
            static var sharedMyModel : AnyObject?
            static var onceToken : dispatch_once_t = 0
        }
        dispatch_once(&Static.onceToken) {
            Static.sharedMyModel = LocationShareModel()
        }
        return Static.sharedMyModel!
    }
}
