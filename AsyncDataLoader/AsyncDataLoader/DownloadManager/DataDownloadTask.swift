//
//  DownloadTask.swift
//  AsyncDataLoader
//
//  Created by NoboPay on 18/6/19.
//  Copyright © 2019 Mostafizur. All rights reserved.
//

import UIKit


enum DataType:String{
    case image = "IMAGE"
    case json = "JSON"
    case zip = "ZIP"
    case xml = "XML"
    case plain = "PLAIN TEXT"
    case raw = "RAW"
}

class DataDownloadTask: BaseDataTask {
    
    var forcedCacel = false
    var completionHandlers: [String : ((Data?,DataType?, Error?) -> Void)?] = [:]
    var progressHandlers: [String : ((Float) -> Void?)?] = [:]
    var cancelHandlers:[String : (()->Void?)?] = [:]
    var beginingHandlers:[String : ((Int64,DataType) -> Void?)?] = [:]
    var dataType:DataType = .raw
    var downloadDelegates:[String : DownloadCompletionDelegate?] = [:]
    var dataSize:Int64 = 0
    private(set) var dataTask: URLSessionDataTask
    var buffer:Data = Data()
    
    
    init(WithTask task:URLSessionDataTask) {
        self.dataTask = task
    }
    
    deinit {
        print("Deinit: \(dataTask.originalRequest?.url?.absoluteString ?? "")")
    }
    
    
    func resume() {
        self.dataTask.resume()
    }
    
    func suspend() {
        
        self.dataTask.suspend()
    }
    
    func cancel() {
        self.dataTask.cancel()

    }
}


extension String {
    func getDataType()->DataType{
        let value = self
        if value.elementsEqual("image/jpeg") ||
         value.elementsEqual("image/png") ||
         value.elementsEqual("image/jpg")
            ||  value.elementsEqual("image/gif") {
            return .image
        }
        
        if value.elementsEqual("text/json") ||
            value.elementsEqual("application/json"){
            return .json
        }
        
        if value.elementsEqual("text/plain") {
            return .plain
        }
        
        if value.elementsEqual("text/xml")  {
            return .xml
        }
        return .raw
        
    }
}
