//
//  AsyncDataLoader.swift
//  AsyncDataLoader
//
//  Created by NoboPay on 18/6/19.
//  Copyright © 2019 Mostafizur. All rights reserved.
//

import UIKit

class AsyncDataLoader: NSObject {

    
    var downloadSession:URLSession?
    var downloadTaskArray:[DataDownloadTask] = []
    
    override init() {
        super.init()
//        let queue = OperationQueue.main
        let configuration = URLSessionConfiguration.default
        self.downloadSession = URLSession(configuration: configuration,
                                          delegate: self,
                                          delegateQueue: nil)
    }
    
    
    
    
    
    
    
    
    func cancelDownload(ForRemotePath remotePath:String)->Bool{
        let (_,_index) = self.getTask(ForUrl: remotePath)
        guard let index = _index else {return false}
        let downloadTask = self.downloadTaskArray.remove(at: index)
        downloadTask.cancel()
        return true
    }
    
    func resumeSuspendedDownload(ForPath urlPath:String)->Bool{
        let (task,_) = self.getTask(ForUrl: urlPath)
        if let downloadTask = task {
            downloadTask.resume()
            return true
        }
        return false
    }
    
    func getRequest(From urlPath:String) -> URLRequest? {
        guard let dataUrl = URL(string: urlPath) else {
            return nil
        }
        
        let request = URLRequest(url: dataUrl,
                                 cachePolicy: .reloadIgnoringLocalCacheData,
                                 timeoutInterval: 60)
        return request
    }
    
    func getTask(ForUrl urlPath:String) -> (DataDownloadTask?, Int?) {
        
        if let index = self.downloadTaskArray.firstIndex(where: { (downloadTask) -> Bool in
            if let request = downloadTask.dataTask.originalRequest,
                let urlPath = request.url?.path {
                return urlPath.elementsEqual(urlPath)
            }
            return false
        }) {
            let downloadTask = self.downloadTaskArray[index]
            return (downloadTask, index)
        }
        return (nil, nil)
    }
    
    func getUrlError()->DataError{
        return DataError(title: "Bad url",
                         description: "http url is in bad format.", code: 1000)
    }
    
    func getDownloadError()->DataError{
        return DataError(title: "Download Fail",
                  description: "Unable to initiate download process.", code: 1001)
    }
    
    
    func didResponsed(ForTask task:DataDownloadTask){
        assertionFailure("must be overriden by child")
    }
    
    func completing(Percent percent:Float, ofTask task:DataDownloadTask)  {
        assertionFailure("must be overriden by child")
    }
    
    func finished(Task data:DataDownloadTask, Error error:Error?){
        assertionFailure("must be overriden by child")
    }
}

extension AsyncDataLoader:URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        guard let task = self.downloadTaskArray.first(where: { $0.dataTask == dataTask }) else {
            completionHandler(.cancel)
            return
        }
        if let type = response.mimeType {
            task.dataType = type.getDataType()
        }
        task.dataSize = response.expectedContentLength
        self.didResponsed(ForTask: task)
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let task = downloadTaskArray.first(where: { $0.dataTask == dataTask }) else {
            return
        }
        task.buffer.append(data)
        let percentageDownloaded = Float(task.buffer.count) / Float(task.dataSize)
       self.completing(Percent: percentageDownloaded, ofTask: task)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        guard let index = downloadTaskArray.firstIndex(where: { $0.dataTask == task }) else {
            return
        }
        let task = downloadTaskArray.remove(at: index)
        self.finished(Task: task, Error: error)
    }
}


