//
//  ViewController.swift
//  Future
//
//  Created by Adrián Ferreyra.
//  @_AdrianFerreyra.
//
//  Copyright (c) 2015 Adrián Ferreyra. All rights reserved.
//
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let getResponseString = { unit($0) >>>= getURL >>>= httpGet >>>= responseString }
        
        let response = getResponseString("http://nsconfarg.com")
        
        response.callback = {println("\($0)")}
    }
}

//Functions

func getURL (s:String?) -> Future<NSURL> {
    println("GetURL")
    var returnFuture = Future<NSURL>()
    
    if let unwrappedString = s {
        returnFuture.result = .Finished(NSURL(string: unwrappedString))
    } else {
        returnFuture.result = .Finished(nil)
    }
    
    return returnFuture
}

func httpGet (s:NSURL?) -> Future<NSData> {
    println("httpGet")
    var returnFuture = Future<NSData>()
    
    if let unwrappedURL = s {
        let task = NSURLSession.sharedSession().dataTaskWithURL(unwrappedURL) {(data, response, error) in
            if((error) != nil) {
                returnFuture.result = .Finished(nil)
            } else {
                returnFuture.result = .Finished(data)
            }
        }
        
        task.resume()
        
    } else {
        returnFuture.result = .Finished(nil)
    }
    
    return returnFuture
}

func responseString (data:NSData?) -> Future<String> {
    println("responseString")
    var returnFuture = Future<String>()
    
    if let unwrappedData = data {
        returnFuture.result = .Finished(NSString(data: unwrappedData, encoding: NSUTF8StringEncoding) as? String)
    } else {
        returnFuture.result = .Finished(nil)
    }
    
    return returnFuture
}