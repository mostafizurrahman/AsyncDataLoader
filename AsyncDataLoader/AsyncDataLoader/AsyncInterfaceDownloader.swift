//
//  AsyncInterfaceDownloader.swift
//  AsyncDataLoader
//
//  Created by Mostafizur Rahman on 20/6/19.
//  Copyright © 2019 Mostafizur. All rights reserved.
//

import UIKit

class AsyncInterfaceDownloader: AsyncDataLoader {

    var downloadDelegates:[DownloadCompletionDelegate] = []
//    convenience init(WithDelegate delegate:Any) {
//        self.init()
//        self.downloadDelegate = delegate as? DownloadCompletionDelegate
//    }
    
    //befor calling this method
    //set delegation 'downloadDelegate:DownloadCompletionDelegate'
    func download(FromPath urlPath:String, DelegateTo delegate: DownloadCompletionDelegate){
        
//        assert(self.downloadDelegate != nil, "`downloadDelegate:DownloadCompletionDelegate?` Must not be nil for downloading data without blocks.")
        assert(delegate.responds(to: Selector(("onDownloadCancel"))), "Delegate methods not implemented.")
        let (_data, _type) = CacheManager.shared.getObject(ForKey: urlPath as NSString)
        if let data = _data, let type = _type {
            delegate.onCompleted(Parcent: 1.0)
            delegate.onDownloadCompleted(WithData: data, Type: type, Error: nil)
        } else {
            for downloadTask in self.downloadTaskArray {
                if downloadTask.dataTask.originalRequest?.url?.path.elementsEqual(urlPath) ?? false {
                    downloadTask.downloadDelegates.append(delegate)
                    return
                }
            }
            guard let request = self.getRequest(From: urlPath) else {return}
            guard let task = self.downloadSession?.dataTask(with: request) else {
                delegate.onDownloadCompleted(WithData: nil, Type: nil, Error: getDownloadError())
                return
            }
            let downloadTask = DataDownloadTask(WithTask: task)
            self.downloadDelegates.append(delegate)
            downloadTask.downloadDelegates.append(delegate)
            self.downloadTaskArray.append(downloadTask)
            downloadTask.resume()
        }
        
    }
    
    override func didResponsed(ForTask task:DataDownloadTask) {
        DispatchQueue.main.async {
            for delegate in task.downloadDelegates {
                delegate?.willBegin(WithSize: task.dataSize, type: task.dataType)
            }
        }
    }
    override func completing(Percent percent:Float, ofTask task:DataDownloadTask){
        DispatchQueue.main.async {
            for delegate in task.downloadDelegates {
                delegate?.onCompleted(Parcent: percent)
            }
        }
    }
    
    override func finished(Task task:DataDownloadTask, Error error:Error?){
        DispatchQueue.main.async {
            for delegate in task.downloadDelegates {
                delegate?.onDownloadCompleted(WithData: task.buffer,
                                              Type:task.dataType,
                                              Error: error)
            }
            task.downloadDelegates.removeAll()
        }
    }
}
