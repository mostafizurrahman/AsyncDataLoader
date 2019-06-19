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
    }
    
    override func didResponsed(ForTask task:DataDownloadTask){
        DispatchQueue.main.async {
            if let begin = task.beginingHandler {
                begin(task.dataSize, task.dataType)
            }
        }
    }
    
    override func completing(Percent percent:Float, ofTask task:DataDownloadTask)  {
        DispatchQueue.main.async {
             if let progressHandler = task.progressHandler {
                progressHandler(percent)
            }
        }
    }
    
    override func finished(Task task:DataDownloadTask, Error error:Error?){
        DispatchQueue.main.async {
            if let completionHandler = task.completionHandler {
                completionHandler(task.buffer, error)
            }
        }
    }
}
