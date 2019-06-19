//
//  AsyncDataLoader.swift
//  AsyncDataLoader
//
//  Created by NoboPay on 18/6/19.
//  Copyright © 2019 Mostafizur. All rights reserved.
//

import UIKit

class AsyncDataLoader: NSObject {

    
    
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
//        let queue = OperationQueue.main
        let configuration = URLSessionConfiguration.default
        self.downloadSession = URLSession(configuration: configuration,
                                          delegate: self,
                                          delegateQueue: nil)
    }
    
    convenience init(WithDelegate delegate:Any) {
        self.init()
        self.downloadDelegate = delegate as? DownloadCompletionDelegate
    }
    
    //befor calling this method
    //set delegation 'downloadDelegate:DownloadCompletionDelegate'
    func download(FromPath urlPath:String){
        assert(self.downloadDelegate != nil, "`downloadDelegate:DownloadCompletionDelegate?` Must not be nil for downloading data without blocks.")
        guard let request = self.getRequest(From: urlPath) else {return}
        guard let task = self.downloadSession?.dataTask(with: request) else {
            self.downloadDelegate?.onDownload(Error: getDownloadError())
            return
        }
        let downloadTask = DataDownloadTask(WithTask: task)
        downloadTask.downloadDelegate = self.downloadDelegate
        self.downloadTaskArray.append(downloadTask)
        downloadTask.resume()
    }
    
    
    //download using completion blocks
    func download(From urlPath:String,
                  progressHandler:@escaping ((Float) -> Void?),
                  cancelHandler:(()->Void?)?,
                  suspendHandler:(()->Void?)?,
                  completionHandler: @escaping (Data?, Error?)->Void){
        
        guard let request = self.getRequest(From: urlPath) else {
            completionHandler(nil, getUrlError())
            return
        }
        guard let task = self.downloadSession?.dataTask(with: request) else {
            completionHandler(nil, getDownloadError())
            return
        }
        let downloadTask = DataDownloadTask(WithTask: task)
        downloadTask.completionHandler = completionHandler
        downloadTask.cancelHandler = cancelHandler
        downloadTask.suspendHandler = suspendHandler
        downloadTask.progressHandler = progressHandler
        self.downloadTaskArray.append(downloadTask)
        downloadTask.resume()
        
        //        let task = downloadSession?.dataTask(with: <#T##URLRequest#>)
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
    
    fileprivate func getRequest(From urlPath:String) -> URLRequest? {
        guard let dataUrl = URL(string: urlPath) else {
            self.downloadDelegate?.onDownload(Error: getUrlError())
            return nil
        }
        
        let request = URLRequest(url: dataUrl,
                                 cachePolicy: .reloadIgnoringLocalCacheData,
                                 timeoutInterval: 60)
        return request
    }
    
    fileprivate func getTask(ForUrl urlPath:String) -> (DataDownloadTask?, Int?) {
        
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
    
    fileprivate func getUrlError()->DataError{
        return DataError(title: "Bad url",
                         description: "http url is in bad format.", code: 1000)
    }
    
    fileprivate func getDownloadError()->DataError{
        return DataError(title: "Download Fail",
                  description: "Unable to initiate download process.", code: 1001)
    }
}

extension AsyncDataLoader:URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        guard let task = self.downloadTaskArray.first(where: { $0.dataTask == dataTask }) else {
            completionHandler(.cancel)
            return
        }
        
        print(response.mimeType) // check this value for image/json/or other file format
        task.dataSize = response.expectedContentLength
       
        DispatchQueue.main.async {
            if let delegate = self.downloadDelegate {
                delegate.willBegin(WithSize: task.dataSize, type: .raw)
            } else if let begin = task.beginingHandler {
                begin(task.dataSize, .raw)
            }
        }
        completionHandler(.allow)
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
            if let delegate = self.downloadDelegate {
                delegate.onDownloadCompleted(WithData: task.buffer, Error: error)
            } else if let completionHandler = task.completionHandler {
                completionHandler(task.buffer, error)
            }
        }
    }
}

