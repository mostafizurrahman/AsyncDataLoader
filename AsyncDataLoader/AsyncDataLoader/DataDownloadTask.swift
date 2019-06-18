//
//  DownloadTask.swift
//  AsyncDataLoader
//
//  Created by NoboPay on 18/6/19.
//  Copyright © 2019 Mostafizur. All rights reserved.
//

import UIKit


class DataDownloadTask: BaseDataTask {
    
    var completionHandler: ((Data?, Bool, Error?) -> Void)?
    var progressHandler: ((Float) -> Void?)?
    
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
        
    }
    
    func suspend() {
        
    }
    
    func cancel() {
        
    }
    

    var dataSize:Int64 = 0
    
}
