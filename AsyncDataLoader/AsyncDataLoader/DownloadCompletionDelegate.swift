//
//  DownloadCompletionDelegate.swift
//  AsyncDataLoader
//
//  Created by NoboPay on 18/6/19.
//  Copyright © 2019 Mostafizur. All rights reserved.
//

import UIKit

protocol DownloadCompletionDelegate: NSObjectProtocol {
    
    func onDownloadCompleted(WithData data:Data)
    func onDownload(Error error:Error)
    func onDownloadCancel()
    func onCompleted(Parcent percent:Float)
    

}
