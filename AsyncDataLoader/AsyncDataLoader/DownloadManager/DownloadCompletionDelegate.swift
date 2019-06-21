//
//  DownloadCompletionDelegate.swift
//  AsyncDataLoader
//
//  Created by NoboPay on 18/6/19.
//  Copyright © 2019 Mostafizur. All rights reserved.
//

import UIKit

protocol DownloadCompletionDelegate: NSObjectProtocol {
    
    func didDownloadCompleted(ForID downloadID:String,
                              Data data:Data?,
                              Type type:DataType?,
                              Error error:Error?)
    func didDownloadCanceled(ForID downloadID:String)
    func onCompleted(Parcentage percent:Float,
                     ForID downloadID:String)
    func willBeginDownload(WithSize size:Int64,
                           Type type:DataType,
                           ForID downloadID:String)
    func didDownloadSuspended(ForID downloadID:String)
}
