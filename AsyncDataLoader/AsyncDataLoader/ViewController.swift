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
    @IBOutlet weak var percent4: UILabel!
    @IBOutlet weak var percent2: UILabel!
    @IBOutlet weak var percent3: UILabel!
    @IBOutlet weak var percent1: UILabel!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageView4: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView1: UIImageView!
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
        
        downloader.download(From: url1, progressHandler: { (percent) -> Void? in
            self.percent1.text = "completed \(percent)"
        }, cancelHandler: { () -> Void? in
            self.percent1.text = "canceled"
        }, suspendHandler: { () -> Void? in
            self.percent1.text = "suspended"
        }) { (data,type, error) in
            if let _data = data {
                let image = UIImage(data: _data)
                self.imageView1.image = image
            } else if let _err = error as? DataError{
                self.percent1.text = " \(_err.errorDescription)  \(_err.title)"
            }
        }
        
        downloader.download(From: url2, progressHandler: { (percent) -> Void? in
            self.percent2.text = "completed \(percent)"
        }, cancelHandler: { () -> Void? in
            self.percent2.text = "canceled"
        }, suspendHandler: { () -> Void? in
            self.percent2.text = "suspended"
        }) { (data,type, error) in
            if let _data = data {
                let image = UIImage(data: _data)
                self.imageView2.image = image
            }else if let _err = error as? DataError{
                self.percent2.text = " \(_err.errorDescription)  \(_err.title)"
            }
        }

        downloader.download(From: url3, progressHandler: { (percent) -> Void? in
            self.percent3.text = "completed \(percent)"
        }, cancelHandler: { () -> Void? in
            self.percent3.text = "canceled"
        }, suspendHandler: { () -> Void? in
            self.percent3.text = "suspended"
        }) { (data,type, error) in
            if let _data = data {
                let image = UIImage(data: _data)
                self.imageView3.image = image
            } else if let _err = error as? DataError{
                self.percent3.text = " \(_err.errorDescription)  \(_err.title)"
            }
        }

        downloader.download(From: url4, progressHandler: { (percent) -> Void? in
            self.percent4.text = "completed \(percent)"
        }, cancelHandler: { () -> Void? in
            self.percent4.text = "canceled"
        }, suspendHandler: { () -> Void? in
            self.percent4.text = "suspended"
        }) { (data,type, error) in
            if let _data = data {
                let image = UIImage(data: _data)
                self.imageView4.image = image
            }else if let _err = error as? DataError{
                self.percent4.text = " \(_err.errorDescription)  \(_err.title)"
            }
        }
        
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
    
}

