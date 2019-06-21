//
//  BlockViewController.swift
//  AsyncDataLoader
//
//  Created by Mostafizur Rahman on 21/6/19.
//  Copyright © 2019 Mostafizur. All rights reserved.
//

import UIKit

class BlockViewController: UIViewController {
    let blockDownloader = AsyncBlockDownloader()
//    let interfaceDownloader = AsyncInterfaceDownloader()
    @IBOutlet weak var downloadView: DownloaderView!
    
    
    
    
    @IBOutlet weak var multipleDownloadView1: DownloaderView!
    @IBOutlet weak var multipleDownloadView2: DownloaderView!
    
    let jsonarray = AppDelegate.jsonarray
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func startStopDownload(_ sender: UIButton) {
        if let _title = sender.title(for: UIControl.State.normal),
            _title.elementsEqual("  START  ") {
            sender.setTitle("  STOP  ", for: UIControl.State.normal)
            guard let url1 = self.jsonarray[0]["urls"].dictionaryValue["full"]?.stringValue else {
                return
            }
            self.startDownload(FromURL: url1, toDownloadView: self.downloadView)
        } else if let _title = sender.title(for: UIControl.State.normal),
            _title.elementsEqual("  STOP  ") {
            sender.setTitle("  START  ", for: UIControl.State.normal)
            guard let url1 = self.jsonarray[0]["urls"].dictionaryValue["full"]?.stringValue,
            let downloadid = self.downloadView.downloadIdentifier else {
                return
            }
            self.blockDownloader.cancel(DownloadPath: url1, DownloadID: downloadid)
            
        }
        
    }
    
    @IBAction func stopDownload1(_ sender: UIButton) {
        self.stopDownload(ForSender: sender)
    }
    
    @IBAction func stopDownload2(_ sender: UIButton) {
        self.stopDownload(ForSender: sender)
    }
    
    @IBAction func startMultipleDownload(_ sender: Any) {
        guard let url1 = self.jsonarray[4]["urls"].dictionaryValue["full"]?.stringValue else {
            return
        }
        self.startDownload(FromURL: url1, toDownloadView: self.multipleDownloadView1)
        guard let url2 = self.jsonarray[4]["urls"].dictionaryValue["full"]?.stringValue else {
            return
        }
        self.startDownload(FromURL: url2, toDownloadView: self.multipleDownloadView2)
    }
    
    fileprivate func stopDownload(ForSender sender:UIButton){
        
        if let downloderView = sender.superview as? DownloaderView ,
            let id = downloderView.downloadIdentifier,
        let remote = downloderView.remoteUrl{
            print(downloderView.tag)
            self.blockDownloader.cancel(DownloadPath: remote, DownloadID: id)
        }
    }
    
    
    fileprivate func startDownload(FromURL url:String,
                                   toDownloadView downloadView:DownloaderView){
        downloadView.urlLabel.text = "Downloading from \(url)"
        downloadView.remoteUrl = url
        self.blockDownloader.download(From: url, progressHandler: { (percent) in
            
            downloadView.progressView.progress = percent
            downloadView.percentIndicator.text = "Download Completed \(Int(100*percent))%"
            downloadView.circleProgress.setProgressWithAnimation(duration: 0.0, value: percent)
            
        }, cancelHandler: {
            downloadView.percentIndicator.text = "Download has been canceled!"
        }, identifier: { (identifier) in
            downloadView.downloadIdentifier = identifier
        }) { (data, dataType, error) in
            if let _data = data {
                let image = UIImage(data: _data)
                downloadView.imageView.image = image
            } else if let _err = error as? DataError{
                downloadView.percentIndicator.text = "Error \(_err.errorDescription)  \(_err.title)"
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
