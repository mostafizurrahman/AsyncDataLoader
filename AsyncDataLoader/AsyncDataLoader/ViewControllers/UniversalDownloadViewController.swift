//
//  UniversalDownloadViewController.swift
//  AsyncDataLoader
//
//  Created by Mostafizur Rahman on 21/6/19.
//  Copyright © 2019 Mostafizur. All rights reserved.
//

import UIKit

class UniversalDownloadViewController: UIViewController {

    let blockDownloader = AsyncBlockDownloader()
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var textview: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var downloadInfo: UILabel!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var progressLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func autofilleURLField(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 1 {
            self.urlTextField.text = "http://pastebin.com/raw/wgkJgazE"
        } else if sender.selectedSegmentIndex == 0 {
            self.urlTextField.text = AppDelegate.jsonarray[4]["urls"].dictionaryValue["full"]?.stringValue
        } else if sender.selectedSegmentIndex == 2 {
            self.urlTextField.text = "https://www.w3schools.com/xml/plant_catalog.xml"
        } else if sender.selectedSegmentIndex == 3 {
            self.urlTextField.text = "http://api.plos.org/search?q=title:DNA"
        }
    }
    @IBAction func startDownload(_ sender: UIButton) {
        guard let url = self.urlTextField.text, url.count > 4 else {return}
        self.imageView.isHidden = true
        self.textview.isHidden = true
        self.progressView.progress = 0
        sender.isEnabled = false
        self.downloadInfo.text = "Download Info"
        
        let index = url.index(url.startIndex, offsetBy:4)
        let http = String(url[..<index])
        if http.elementsEqual("http") {
            
            
            self.blockDownloader.download(From: url, beginHandler: {(dataSize, dataType)in
                let bcf = ByteCountFormatter()
                bcf.allowedUnits = [.useKB]
                bcf.countStyle = .file
                let sizeMB = bcf.string(fromByteCount: dataSize)
                self.downloadInfo.text = "Downloading \(sizeMB)\n of type \(dataType.rawValue)"
            }, progressHandler: { (percent) in
                
                self.progressView.progress = percent
                self.progressLabel.text = "Downloading \(Int(100 * percent)) %"
            }, cancelHandler: {
                sender.isEnabled = true
//                downloadView.percentIndicator.text = "Download has been canceled!"
            }, identifier: { (identifier) in
//                downloadView.downloadIdentifier = identifier
            }) { (data, dataType, error) in
                
                sender.isEnabled = true
                if let _data = data {
                    
                    if dataType == .image {
                        self.imageView.isHidden = false
                        let image = UIImage(data: _data)
                        self.imageView.image = image
                    } else if dataType == .xml
                     || dataType == .json
                    || dataType == .plain {
                        self.textview.isHidden = false
                        let string = String(data: _data, encoding: .utf8)
                        self.textview.text = string
                    }
                    
                } else if let _err = error as? DataError{
//                    downloadView.percentIndicator.text = "Error \(_err.errorDescription)  \(_err.title)"
                }
            }
        }
        
    }
    
    fileprivate func startDownload(FromURL url:String,
                                   toDownloadView downloadView:DownloaderView){
        
        
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
