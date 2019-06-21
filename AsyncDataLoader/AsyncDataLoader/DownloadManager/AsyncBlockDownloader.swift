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
                  beginHandler:@escaping ((Int64, DataType)->Void),
                  progressHandler:@escaping ((Float) -> Void),
                  cancelHandler:@escaping (()->Void),
                  identifier:((String?)->Void),
                  completionHandler: @escaping (Data?,DataType?, Error?)->Void){
        
        let (_data, _type) = CacheManager.shared.getObject(ForKey: urlPath as NSString)
        if let data = _data, let type = _type {
            progressHandler(1)
            completionHandler(data,type, nil)
        } else {
            let downloadKey = super.getID()
            print(downloadKey)
            for downloadTask in self.downloadTaskArray {
                if downloadTask.dataTask.originalRequest?.url?.absoluteString.elementsEqual(urlPath) ?? false {
                    downloadTask.beginingHandlers[downloadKey] = beginHandler
                    downloadTask.completionHandlers[downloadKey] = completionHandler
                    downloadTask.cancelHandlers[downloadKey] = cancelHandler
                    downloadTask.progressHandlers[downloadKey] = progressHandler
                    identifier(downloadKey)
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
            downloadTask.beginingHandlers[downloadKey] = beginHandler
            downloadTask.completionHandlers[downloadKey] = completionHandler
            downloadTask.cancelHandlers[downloadKey] = cancelHandler
            downloadTask.progressHandlers[downloadKey] = progressHandler
            self.downloadTaskArray.append(downloadTask)
            downloadTask.resume()
            identifier(downloadKey)
        }
    }
    
    override internal func didResponsed(ForTask task:DataDownloadTask){
        DispatchQueue.main.async {
            for begin in task.beginingHandlers {
                if let beginHanderl = begin.value {
                    beginHanderl(task.dataSize, task.dataType)
                }
            }
        }
    }
    
    override internal func completing(Percent percent:Float, ofTask task:DataDownloadTask)  {
        DispatchQueue.main.async {
            for progress in task.progressHandlers {
                if let progressHandler = progress.value {
                    progressHandler(percent)
                }
            }
        }
    }
    
    override internal func finished(Task task:DataDownloadTask, Error error:Error?){
        DispatchQueue.main.async {
            for completion in task.completionHandlers {
                if let completionHandler = completion.value {
                    completionHandler(task.buffer,task.dataType, error)
                }
            }
            self.cacheData(Task: task)
            self.clear(Task: task)
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
    
    fileprivate func cancel(_ task:DataDownloadTask){
        for handler in task.cancelHandlers {
            if let cancelHandler = handler.value {
                cancelHandler()
            }
        }
    }
    
    override internal func cancel(Task task:DataDownloadTask, Key key:String ) {
        
        task.beginingHandlers.removeValue(forKey: key)
        task.progressHandlers.removeValue(forKey: key)
        task.completionHandlers.removeValue(forKey: key)
        task.beginingHandlers.removeValue(forKey: key)
        if let cancelBlock = task.cancelHandlers.removeValue(forKey: key) {
            cancelBlock?()
        }
        if task.completionHandlers.count == 0 {
            task.cancel()
        }
        print(task.progressHandlers.count)
    }
    
    override internal func clear(Task dataTask: DataDownloadTask) {
        dataTask.beginingHandlers.removeAll()
        dataTask.cancelHandlers.removeAll()
        dataTask.completionHandlers.removeAll()
        dataTask.progressHandlers.removeAll()
    }
}
