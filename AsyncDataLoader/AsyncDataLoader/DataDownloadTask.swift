//
//  DownloadTask.swift
//  AsyncDataLoader
//
//  Created by NoboPay on 18/6/19.
//  Copyright © 2019 Mostafizur. All rights reserved.
//

import UIKit


enum DataType:Int{
    case image = 0
    case json = 1
    case zip = 2
    case xml = 3
    case raw = 4
}

class DataDownloadTask: BaseDataTask {
    
    var completionHandlers: [String : ((Data?,DataType?, Error?) -> Void)?] = [:]
    var progressHandlers: [String : ((Float) -> Void?)?] = [:]
    var cancelHandlers:[String : (()->Void?)?] = [:]
    var suspendHandlers:[String : (()->Void?)?] = [:]
    var beginingHandlers:[String : ((Int64,DataType) -> Void?)?] = [:]
    var dataType:DataType = .raw
    
    var downloadDelegates:[String : DownloadCompletionDelegate?] = [:]
    
    private(set) var dataTask: URLSessionDataTask
    var dataFileLength:Int64 = 0
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
    

    var dataSize:Int64 = 0
    
}


extension String {
    func getDataType()->DataType{
        let value = self
        if value.elementsEqual("jpeg/image") ||
         value.elementsEqual("png/image") ||
         value.elementsEqual("jpg/image")
            ||  value.elementsEqual("gif/image") {
            return .image
        }
        
        if value.elementsEqual("text/json")  {
            return .json
        }
        
        if value.elementsEqual("text/xml")  {
            return .xml
        }
        return .raw
        
    }
}
