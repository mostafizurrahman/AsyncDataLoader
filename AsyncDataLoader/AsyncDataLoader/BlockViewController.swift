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
            self.downloadView.urlLabel.text = "Downloading from \(url1)"
            self.blockDownloader.download(From: url1, progressHandler: { (percent) in
                
                    self.downloadView.progressView.progress = percent
                    self.downloadView.percentIndicator.text = "Download Completed \(percent)"
                    self.downloadView.circleProgress.setProgressWithAnimation(duration: 0.0, value: percent)

            }, cancelHandler: {
                self.downloadView.percentIndicator.text = "Download has been canceled!"
            }, identifier: { (identifier) in
                self.downloadView.downloadIdentifier = identifier
            }) { (data, dataType, error) in
                if let _data = data {
                    let image = UIImage(data: _data)
                    self.downloadView.imageView.image = image
                } else if let _err = error as? DataError{
                    self.downloadView.percentIndicator.text = "Error \(_err.errorDescription)  \(_err.title)"
                }

            }
            
            
            
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
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
