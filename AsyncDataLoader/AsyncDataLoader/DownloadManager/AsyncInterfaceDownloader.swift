//
//  AsyncInterfaceDownloader.swift
//  AsyncDataLoader
//
//  Created by Mostafizur Rahman on 20/6/19.
//  Copyright © 2019 Mostafizur. All rights reserved.
//

import UIKit

class AsyncInterfaceDownloader: AsyncDataLoader {

    
    
    //1. first object retured is a download id to track an individual download process
    //this first object will be used to determine finished, cancel particular download process
    //associated with the id. if any error occured to nitiate download, this object will be nil
    //2. sencond parameter is Data that is found in the cache, if ther is no
    //caceched data then it will be nil
    //3. third object retured by this method is a data type of the cached object
    func download(FromPath urlPath:String, DelegateTo delegate: DownloadCompletionDelegate)->(String?, Data?, DataType?){
        
        
        let (_data, _type) = CacheManager.shared.getObject(ForKey: urlPath as NSString)
        if let data = _data, let type = _type {
            return (nil, data, type)
        }
        let downloadKey = super.getID()
        for downloadTask in self.downloadTaskArray {
            if downloadTask.dataTask.originalRequest?.url?.absoluteString.elementsEqual(urlPath) ?? false {
                downloadTask.downloadDelegates[downloadKey] = delegate
                return (downloadKey, nil, nil)
            }
        }
        guard let request = self.getRequest(From: urlPath) else {return (nil, nil, nil)}
        guard let task = self.downloadSession?.dataTask(with: request) else {
            delegate.didDownloadCompleted(ForID: "", Data: nil, Type: nil, Error: self.getDownloadError())
            return (nil, nil, nil)
        }
        let downloadTask = DataDownloadTask(WithTask: task)
        downloadTask.downloadDelegates[downloadKey] = delegate
        self.downloadTaskArray.append(downloadTask)
        downloadTask.resume()
        return (downloadKey, nil, nil)
    }
    
    override internal func didResponsed(ForTask task:DataDownloadTask) {
        DispatchQueue.main.async {
            for delegate in task.downloadDelegates {
                if let downloadDelegate = delegate.value {
                    downloadDelegate.willBeginDownload(WithSize: task.dataSize,
                                                       Type: task.dataType,
                                                       ForID: delegate.key)
                }
            }
        }
    }
    override internal func completing(Percent percent:Float, ofTask task:DataDownloadTask){
        DispatchQueue.main.async {
            for delegate in task.downloadDelegates {
                if let downloadDelegate = delegate.value {
                    downloadDelegate.onCompleted(Parcentage: percent, ForID: delegate.key)
                }
            }
        }
    }
    
    override internal func finished(Task task:DataDownloadTask, Error error:Error?){
        DispatchQueue.main.async {
            for delegate in task.downloadDelegates {
                if let downloadDelegate = delegate.value {
                    downloadDelegate.didDownloadCompleted(ForID: delegate.key,
                                                          Data: task.buffer,
                                                          Type: task.dataType,
                                                          Error: error)
                }
            }
            self.cacheData(Task: task)
            task.downloadDelegates.removeAll()
        }
    }
    
    override func cancelAllDownloads(ForUrl remotePath:String)->DataDownloadTask? {
        let dataTask = super.cancelAllDownloads(ForUrl: remotePath)
        if let task = dataTask {
            self.cancel(task)
            self.clear(Task: task)
            task.cancel()
        }
        return dataTask
    }
    override internal func cancel(Task task:DataDownloadTask, Key key:String ) {
        let delegate = task.downloadDelegates.removeValue(forKey: key) as? DownloadCompletionDelegate
        delegate?.didDownloadCanceled(ForID: key)
        if task.downloadDelegates.count == 0 {
            task.cancel()
        }
    }
    
    override internal func clear(Task dataTask: DataDownloadTask) {
        dataTask.downloadDelegates.removeAll()
    }
    
    fileprivate func cancel(_ task:DataDownloadTask){
        for delegate in task.downloadDelegates {
            if let cancelDelegate = delegate.value {
                cancelDelegate.didDownloadCanceled(ForID: delegate.key)
            }
        }
    }
}
