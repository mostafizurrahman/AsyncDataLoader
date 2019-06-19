//
//  AsyncInterfaceDownloader.swift
//  AsyncDataLoader
//
//  Created by Mostafizur Rahman on 20/6/19.
//  Copyright © 2019 Mostafizur. All rights reserved.
//

import UIKit

class AsyncInterfaceDownloader: AsyncDataLoader {

    weak var downloadDelegate:DownloadCompletionDelegate?
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
    
    override func didResponsed(ForTask task:DataDownloadTask) {
        DispatchQueue.main.async {
            if let delegate = task.downloadDelegate {
                delegate.willBegin(WithSize: task.dataSize, type: task.dataType)
            }
        }
    }
    override func completing(Percent percent:Float, ofTask task:DataDownloadTask){
        DispatchQueue.main.async {
            if let delegate = task.downloadDelegate {
                delegate.onCompleted(Parcent: percent)
            }
        }
    }
    
    override func finished(Task task:DataDownloadTask, Error error:Error?){
        DispatchQueue.main.async {
            if let delegate = task.downloadDelegate {
                delegate.onDownloadCompleted(WithData: task.buffer, Error: error)
            }
        }
    }
}
