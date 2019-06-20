//
//  ViewController.swift
//  AsyncDataLoader
//
//  Created by NoboPay on 17/6/19.
//  Copyright © 2019 Mostafizur. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    
    let downloader = AsyncBlockDownloader()
    let downloader1 = AsyncInterfaceDownloader()
    @IBOutlet weak var percent4: UILabel!
    @IBOutlet weak var percent2: UILabel!
    @IBOutlet weak var percent3: UILabel!
    @IBOutlet weak var percent1: UILabel!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageView4: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView1: UIImageView!
    var dictionary:[String : AnyObject] = [:]
    var jsonarray:[JSON] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        if let path = Bundle.main.url(forResource: "Images", withExtension: "json") {
            let data = try! Data.init(contentsOf: path, options: Data.ReadingOptions.uncached)
            let jsonData = JSON(data: data)
            self.jsonarray = jsonData.arrayValue
        }
        // Do any additional setup after loading the view.
    }

    var label:UILabel?
    var imageView:UIImageView?
    
    @IBAction func download(_ sender: Any) {
        
        guard let url1 = self.jsonarray[0]["urls"].dictionaryValue["full"]?.stringValue else {
            return
        }
        guard let url2 = self.jsonarray[1]["urls"].dictionaryValue["full"]?.stringValue else {
            return
        }
        guard let url3 = self.jsonarray[4]["urls"].dictionaryValue["full"]?.stringValue else {
            return
        }
        guard let url4 = self.jsonarray[3]["urls"].dictionaryValue["full"]?.stringValue else {
            return
        }
        self.imageView1.image = nil
        self.imageView2.image = nil
        self.imageView3.image = nil
        self.imageView4.image = nil
        
        
        imageView = self.imageView1
        label = percent1
        if let idf1 = self.downloader1.download(FromPath: url1, DelegateTo: self) {
            self.dictionary[idf1] = [self.imageView1, self.percent1] as AnyObject
        }
        
        imageView = self.imageView2
        label = percent2
        
        if let idf2 = self.downloader1.download(FromPath: url2, DelegateTo: self) {
            self.dictionary[idf2] = [self.imageView2, self.percent2] as AnyObject
        }
        
        imageView = self.imageView3
        label = percent3
        if let idf3 = self.downloader1.download(FromPath: url3, DelegateTo: self) {
            self.dictionary[idf3] = [self.imageView3, self.percent3] as AnyObject
        }
        
        imageView = self.imageView4
        label = percent4
        if let idf4 = self.downloader1.download(FromPath: url4, DelegateTo: self) {
            self.dictionary[idf4] = [self.imageView4, self.percent4] as AnyObject
        }
        
        
//        downloader.download(From: url1, progressHandler: { (percent) -> Void? in
//            self.percent1.text = "completed \(percent)"
//        }, cancelHandler: { () -> Void? in
//            self.percent1.text = "canceled"
//        }, suspendHandler: { () -> Void? in
//            self.percent1.text = "suspended"
//        }) { (data,type, error) in
//            if let _data = data {
//                let image = UIImage(data: _data)
//                self.imageView1.image = image
//            } else if let _err = error as? DataError{
//                self.percent1.text = " \(_err.errorDescription)  \(_err.title)"
//            }
//        }
//
//        downloader.download(From: url2, progressHandler: { (percent) -> Void? in
//            self.percent2.text = "completed \(percent)"
//        }, cancelHandler: { () -> Void? in
//            self.percent2.text = "canceled"
//        }, suspendHandler: { () -> Void? in
//            self.percent2.text = "suspended"
//        }) { (data,type, error) in
//            if let _data = data {
//                let image = UIImage(data: _data)
//                self.imageView2.image = image
//            }else if let _err = error as? DataError{
//                self.percent2.text = " \(_err.errorDescription)  \(_err.title)"
//            }
//        }
//
//        downloader.download(From: url3, progressHandler: { (percent) -> Void? in
//            self.percent3.text = "completed \(percent)"
//        }, cancelHandler: { () -> Void? in
//            self.percent3.text = "canceled"
//        }, suspendHandler: { () -> Void? in
//            self.percent3.text = "suspended"
//        }) { (data,type, error) in
//            if let _data = data {
//                let image = UIImage(data: _data)
//                self.imageView3.image = image
//            } else if let _err = error as? DataError{
//                self.percent3.text = " \(_err.errorDescription)  \(_err.title)"
//            }
//        }
//
//        downloader.download(From: url4, progressHandler: { (percent) -> Void? in
//            self.percent4.text = "completed \(percent)"
//        }, cancelHandler: { () -> Void? in
//            self.percent4.text = "canceled"
//        }, suspendHandler: { () -> Void? in
//            self.percent4.text = "suspended"
//        }) { (data,type, error) in
//            if let _data = data {
//                let image = UIImage(data: _data)
//                self.imageView4.image = image
//            }else if let _err = error as? DataError{
//                self.percent4.text = " \(_err.errorDescription)  \(_err.title)"
//            }
//        }
        
//        downloader.download(From: url1, progressHandler: { (percent) -> Void? in
//            self.percent1.text = "completed \(percent)"
//        }, cancelHandler: { () -> Void? in
//            self.percent1.text = "canceled"
//        }, suspendHandler: { () -> Void? in
//            self.percent1.text = "suspended"
//        }) { (data, error) in
//            if let _data = data {
//                let image = UIImage(data: _data)
//                self.imageView1.image = image
//            }else if let _err = error as? DataError{
//                self.percent1.text = " \(_err.errorDescription)  \(_err.title)"
//            }
//        }
    }
    
    var stop = false
    @IBAction func start1(_ sender: Any) {
        guard let url1 = self.jsonarray[0]["urls"].dictionaryValue["full"]?.stringValue else {
            return
        }
        if stop {
            if let idf = self.dictionary.keys.first {
                self.downloader1.cancel(DownloadPath: url1, DownloadID: idf)
            }
        } else {
            if let idf1 = self.downloader1.download(FromPath: url1, DelegateTo: self) {
                self.dictionary[idf1] = [self.imageView1, self.percent1] as AnyObject
            }
            stop = true
        }
        
    }
    
    @IBAction func start2(_ sender: Any) {
        guard let url1 = self.jsonarray[0]["urls"].dictionaryValue["full"]?.stringValue else {
            return
        }
        if let idf1 = self.downloader1.download(FromPath: url1, DelegateTo: self) {
            self.dictionary[idf1] = [self.imageView2, self.percent2] as AnyObject
        }
    }
    
    
}

extension ViewController : DownloadCompletionDelegate {
    func didDownloadCompleted(ForID downloadID: String,
                              Data data: Data?,
                              Type type: DataType?,
                              Error error: Error?) {
        if let imageView = (self.dictionary[downloadID] as? [AnyObject])?.first as? UIImageView {
            if let _data = data {
                let image = UIImage(data: _data)
                imageView.image = image
            }
        } else {
            if let _data = data {
                let image = UIImage(data: _data)
                imageView?.image = image
            }
        }
    }
    
    func didDownloadCanceled(ForID downloadID: String) {
        self.percent1.text = "Canceled download"
    }
    
    func onCompleted(Parcentage percent: Float,
                     ForID downloadID: String) {
        if let _percent = (self.dictionary[downloadID] as? [AnyObject])?.last as? UILabel {
            _percent.text = "\(percent)"
        } else {
            self.label?.text = "\(percent)"
        }
    }
    
    func willBeginDownload(WithSize size: Int64,
                           Type type: DataType,
                           ForID downloadID: String) {
        
    }
    
    func didDownloadSuspended(ForID downloadID: String) {
        
    }
    
    
    
    
}
