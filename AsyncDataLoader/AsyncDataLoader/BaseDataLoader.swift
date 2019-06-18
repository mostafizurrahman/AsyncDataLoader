//
//  BaseDataLoader.swift
//  AsyncDataLoader
//
//  Created by NoboPay on 18/6/19.
//  Copyright © 2019 Mostafizur. All rights reserved.
//

import UIKit

class BaseDataLoader: NSObject {
    
    weak var downloadDelegate:DownloadCompletionDelegate?
    
    func getDownloadDataSize(url: URL, completion: @escaping (Int64, Error?) -> Void) {
        let timeoutInterval = 1.0
        var request = URLRequest(url: url,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: timeoutInterval)
        request.httpMethod = "HEAD"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            let contentLength = response?.expectedContentLength ?? NSURLSessionTransferSizeUnknown
            completion(contentLength, error)
            }.resume()
    }
    
    
    
    
    private var downloadSession:URLSession?
    
    override init() {
        super.init()
        let queue = OperationQueue.main
        let configuration = URLSessionConfiguration.default
        self.downloadSession = URLSession(configuration: configuration,
                                          delegate: self,
                                          delegateQueue: queue)
    }
    

    func download(

}

extension BaseDataLoader:URLSessionDataDelegate {
    
}
