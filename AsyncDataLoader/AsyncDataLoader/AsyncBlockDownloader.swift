//
//  AsyncBlockDownloader.swift
//  AsyncDataLoader
//
//  Created by Mostafizur Rahman on 20/6/19.
//  Copyright © 2019 Mostafizur. All rights reserved.
//

import UIKit

class AsyncBlockDownloader: AsyncDataLoader {
    
    //download using completion blocks
    func download(From urlPath:String,
                  progressHandler:@escaping ((Float) -> Void?),
                  cancelHandler:(()->Void?)?,
                  suspendHandler:(()->Void?)?,
                  completionHandler: @escaping (Data?,DataType?, Error?)->Void){
        
        let (_data, _type) = CacheManager.shared.getObject(ForKey: urlPath as NSString)
        if let data = _data, let type = _type {
            progressHandler(1)
            completionHandler(data,type, nil)
        } else {
            
            for downloadTask in self.downloadTaskArray {
                if downloadTask.dataTask.originalRequest?.url?.absoluteString.elementsEqual(urlPath) ?? false {
//                    downloadTask.downloadDelegates.append(delegate)
                    downloadTask.completionHandlers.append(completionHandler)
                    downloadTask.cancelHandlers.append(cancelHandler)
                    downloadTask.suspendHandlers.append(suspendHandler)
                    downloadTask.progressHandlers.append(progressHandler)
                    return
                }
            }
            
            guard let request = self.getRequest(From: urlPath) else {
                completionHandler(nil,nil, getUrlError())
                return
            }
            guard let task = self.downloadSession?.dataTask(with: request) else {
                completionHandler(nil,nil, getDownloadError())
                return
            }
            let downloadTask = DataDownloadTask(WithTask: task)
            downloadTask.completionHandlers.append(completionHandler)
            downloadTask.cancelHandlers.append(cancelHandler)
            downloadTask.suspendHandlers.append(suspendHandler)
            downloadTask.progressHandlers.append(progressHandler)
            self.downloadTaskArray.append(downloadTask)
            downloadTask.resume()
        }
    }
    
    override func didResponsed(ForTask task:DataDownloadTask){
        DispatchQueue.main.async {
            for begin in task.beginingHandlers {
                if let beginHanderl = begin {
                    beginHanderl(task.dataSize, task.dataType)
                }
            }
        }
    }
    
    override func completing(Percent percent:Float, ofTask task:DataDownloadTask)  {
        DispatchQueue.main.async {
            for progress in task.progressHandlers {
                if let progressHandler = progress {
                    progressHandler(percent)
                }
            }
        }
    }
    
    override func finished(Task task:DataDownloadTask, Error error:Error?){
        DispatchQueue.main.async {
            for completion in task.completionHandlers {
                if let completionHandler = completion {
                    completionHandler(task.buffer,task.dataType, error)
                }
            }
            self.cacheData(Task: task)
            task.completionHandlers.removeAll()
            task.cancelHandlers.removeAll()
            task.suspendHandlers.removeAll()
            task.progressHandlers.removeAll()
        }
    }
    
    
}
