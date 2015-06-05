//
//  FileLogger.swift
//  LocationStarter1
//
//  Created by S Venu Madhav Chitta on 6/4/15.
//  Copyright (c) 2015 S Venu Madhav Chitta. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation


func trace(msg: String) {
    FileLogger.instance.log(msg)
}



class FileLogger : NSObject {
    let queue = NSOperationQueue()
    var fileHandle: NSFileHandle!
    let dateFormatter: NSDateFormatter
    
    override init() {
        self.dateFormatter = NSDateFormatter()
        self.dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        self.dateFormatter.timeStyle = NSDateFormatterStyle.LongStyle
        super.init()
        queue.maxConcurrentOperationCount = 1
        
        let fm = NSFileManager.defaultManager()
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        let destinationPath = documentsPath.stringByAppendingString("/log.txt")
        
        if !fm.fileExistsAtPath(destinationPath) {
            fm.createFileAtPath(destinationPath,contents: nil, attributes: nil)
        }
        
        let fileHandle = NSFileHandle(forWritingAtPath: destinationPath)
        if fileHandle != nil {
            fileHandle!.seekToEndOfFile()
            self.fileHandle = fileHandle!
        }
    }
    
    class var instance: FileLogger {
        struct Static {
            static let instance: FileLogger = FileLogger()
        }
        return Static.instance
    }
    
    func log(msg: String) {
        NSLog(msg)
        queue.addOperation(LogOperation(msg: msg, fileHandle: self.fileHandle, dateFormatter: self.dateFormatter))
    }
    
    
    private class LogOperation : NSOperation {
        let msg: String
        let fileHandle: NSFileHandle
        let dateFormatter: NSDateFormatter
        let date = NSDate()
        
        init(msg: String, fileHandle: NSFileHandle, dateFormatter: NSDateFormatter) {
            self.msg = msg
            self.fileHandle = fileHandle
            self.dateFormatter = dateFormatter
            super.init()
        }
        
        override func main() -> () {
            let dt = self.dateFormatter.stringFromDate(self.date)
            self.fileHandle.writeData(dt.dataUsingEncoding(NSUTF8StringEncoding)!)
            self.fileHandle.writeData(" ".dataUsingEncoding(NSUTF8StringEncoding)!)
            self.fileHandle.writeData(self.msg.dataUsingEncoding(NSUTF8StringEncoding)!)
            self.fileHandle.writeData("\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        
    }
}