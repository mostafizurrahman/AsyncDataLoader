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
    
    var completionHandler: ((Data?, Bool, Error?) -> Void)?
    var progressHandler: ((Float) -> Void?)?
    var beginingHandler:((Int64) -> Void?)?
    var dataType:DataType = .raw
    weak var downloadDelegate:DownloadCompletionDelegate?
    
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
        
    }
    
    func cancel() {
        
    }
    

    var dataSize:Int64 = 0
    
}
