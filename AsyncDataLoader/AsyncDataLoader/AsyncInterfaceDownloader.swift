//
//  AsyncInterfaceDownloader.swift
//  AsyncDataLoader
//
//  Created by Mostafizur Rahman on 20/6/19.
//  Copyright © 2019 Mostafizur. All rights reserved.
//

import UIKit

class AsyncInterfaceDownloader: AsyncDataLoader {

//    var downloadDelegates:[DownloadCompletionDelegate] = []
//    convenience init(WithDelegate delegate:Any) {
//        self.init()
//        self.downloadDelegate = delegate as? DownloadCompletionDelegate
//    }
    
    //befor calling this method
    //set delegation 'downloadDelegate:DownloadCompletionDelegate'
    func download(FromPath urlPath:String, DelegateTo delegate: DownloadCompletionDelegate)->String?{
        
//        assert(self.downloadDelegate != nil, "`downloadDelegate:DownloadCompletionDelegate?` Must not be nil for downloading data without blocks.")
        assert(delegate.responds(to: Selector(("onDownloadCancel"))), "Delegate methods not implemented.")
        let (_data, _type) = CacheManager.shared.getObject(ForKey: urlPath as NSString)
        if let data = _data, let type = _type {
            delegate.onCompleted(Parcent: 1.0)
            delegate.onDownloadCompleted(WithData: data, Type: type, Error: nil)
        } else {
            let downloadKey = super.getID()
            for downloadTask in self.downloadTaskArray {
                if downloadTask.dataTask.originalRequest?.url?.path.elementsEqual(urlPath) ?? false {
                    downloadTask.downloadDelegates[downloadKey] = delegate
                    return downloadKey
                }
            }
            guard let request = self.getRequest(From: urlPath) else {return nil}
            guard let task = self.downloadSession?.dataTask(with: request) else {
                delegate.onDownloadCompleted(WithData: nil, Type: nil, Error: getDownloadError())
                return nil
            }
            let downloadTask = DataDownloadTask(WithTask: task)
//            self.downloadDelegates.append(delegate)
            downloadTask.downloadDelegates[downloadKey] = delegate
            self.downloadTaskArray.append(downloadTask)
            downloadTask.resume()
            return downloadKey
        }
        return nil
    }
    
    override internal func didResponsed(ForTask task:DataDownloadTask) {
        DispatchQueue.main.async {
            for delegate in task.downloadDelegates {
                if let downloadDelegate = delegate.value {
                    downloadDelegate.willBegin(WithSize: task.dataSize, type: task.dataType)
                }
            }
        }
    }
    override internal func completing(Percent percent:Float, ofTask task:DataDownloadTask){
        DispatchQueue.main.async {
            for delegate in task.downloadDelegates {
                if let downloadDelegate = delegate.value {
                    downloadDelegate.onCompleted(Parcent: percent)
                }
            }
        }
    }
    
    override internal func finished(Task task:DataDownloadTask, Error error:Error?){
        DispatchQueue.main.async {
            for delegate in task.downloadDelegates {
                if let downloadDelegate = delegate.value {
                    downloadDelegate.onDownloadCompleted(WithData: task.buffer,
                                                         Type:task.dataType,
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
        }
        return dataTask
    }
    override internal func cancel(Task task:DataDownloadTask, Key key:String ) {
        self.cancel(task)
        task.downloadDelegates.removeValue(forKey: key)
    }
    
    override internal func clear(Task dataTask: DataDownloadTask) {
        dataTask.downloadDelegates.removeAll()
    }
    
    fileprivate func cancel(_ task:DataDownloadTask){
        for delegate in task.downloadDelegates {
            if let cancelDelegate = delegate.value {
                cancelDelegate.onDownloadCancel()
            }
        }
    }
}
