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
    private var downloadTaskArray:[DataDownloadTask] = []
    
    override init() {
        super.init()
        let queue = OperationQueue.main
        let configuration = URLSessionConfiguration.default
        self.downloadSession = URLSession(configuration: configuration,
                                          delegate: self,
                                          delegateQueue: queue)
    }
    
    convenience init(WithDelegate delegate:Any) {
        self.init()
        self.downloadDelegate = delegate as? DownloadCompletionDelegate
    }

    //befor calling this method
    //set delegation 'downloadDelegate:DownloadCompletionDelegate'
    func download(FromPath urlPath:String){
        guard let dataUrl = URL(string: urlPath) else {
            let error = DataError(title: "Bad url",
                                  description: "http url is in bad format.", code: 1000)
            self.downloadDelegate?.onDownload(Error: error)
            return
        }
        
        let request = URLRequest(url: dataUrl,
                                 cachePolicy: .reloadIgnoringLocalCacheData,
                                 timeoutInterval: 10)

        guard let task = self.downloadSession?.dataTask(with: request) else {
            let error = DataError(title: "Download Fail",
                                  description: "Unable to initiate download process.", code: 1001)
            self.downloadDelegate?.onDownload(Error: error)
            return
        }
        let downloadTask = DataDownloadTask(WithTask: task)
        downloadTask.downloadDelegate = self.downloadDelegate
        self.downloadTaskArray.append(downloadTask)
        downloadTask.resume()
    }
    
    
    //download using completion blocks
    func download(From path:String, progressHandler: ((Float) -> Void?),
                  completionHandler: @escaping (Data, Bool, Error?)->Void){
        
//        let task = downloadSession?.dataTask(with: <#T##URLRequest#>)
    }

}

extension BaseDataLoader:URLSessionDataDelegate {

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        guard let task = self.downloadTaskArray.first(where: { $0.dataTask == dataTask }) else {
            completionHandler(.cancel)
            return
        }
        
        task.dataSize = response.expectedContentLength
        completionHandler(.allow)
        DispatchQueue.main.async {
            if let delegate = self.downloadDelegate {
                delegate.willBegin(WithSize: task.dataSize)
            } else if let begin = task.beginingHandler {
                begin(task.dataSize)
            }
        }
        
        
        print(response.mimeType)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let task = downloadTaskArray.first(where: { $0.dataTask == dataTask }) else {
            return
        }
        task.buffer.append(data)
        let percentageDownloaded = Float(task.buffer.count) / Float(task.dataSize)
        DispatchQueue.main.async {
            if let delegate = self.downloadDelegate {
                delegate.didCompleted(Percentage: percentageDownloaded)
            } else if let progressHandler = task.progressHandler {
                progressHandler(percentageDownloaded)
            }
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        guard let index = downloadTaskArray.firstIndex(where: { $0.dataTask == task }) else {
            return
        }
        let task = downloadTaskArray.remove(at: index)
        DispatchQueue.main.async {
//            if let e = error {
//                task.completionHandler?(.failure(e))
//            } else {
//                task.completionHandler?(.success(task.buffer))
//            }
        }
    }
}
