//
//  callService.swift
//  Gaceta Parlamentaria
//
//  Created by Armando Trujillo on 06/03/15.
//  Copyright (c) 2015 RedRabbit. All rights reserved.
//

import UIKit

class callService: NSObject {
    
    private var formPost : NSString = ""
    private var formGet : NSString = ""
    var url : String = ""
    var httpMethod = ""
    
    func callService() -> NSDictionary {
        
        if httpMethod == "GET" {
            self.url = self.url + "?" + (formGet as String)
        }
        
        let url : NSURL = NSURL(string: self.url)!
        let request : NSMutableURLRequest = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = httpMethod
        
        if httpMethod == "POST" {
            let postData : NSData = formPost.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)!
            request.HTTPBody = postData
        }
        
        var response : AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
        var error : NSErrorPointer = nil
        
        var returnData : NSData!
        request.timeoutInterval = 30
        
        println("Calling Service...")
        let urlCon = NSURLConnection()
        returnData =  NSURLConnection.sendSynchronousRequest(request, returningResponse: response, error: error)
        var err : NSError
        
        if returnData != nil {
            var resultString : NSString = ""
            resultString = NSString(data: returnData, encoding: NSUTF8StringEncoding)!
            println(resultString)
            let dataExa : NSData = resultString.dataUsingEncoding(NSUTF8StringEncoding)!
            if var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(dataExa, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary {
                println( jsonResult )
                return jsonResult
            }
            
        }
        println("Falling Service...")
        
        return NSDictionary()
        
    }
    
    func addParamPOSTWithKey(keyForm : String, andValue value : String)  {
        if formPost == "" {
            formPost = keyForm + "=" + value
        } else {
            formPost = (formPost as String) + "&" + keyForm + "=" + value
        }
    }
    
    func addParamGETWithKey(keyGet: String, andValue value : String){
        if formGet == "" {
            formGet = keyGet + "=" + value
        } else {
            formGet = (formGet as String) + "&" + keyGet + "=" + value
        }
    }
}
