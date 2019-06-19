//
//  ViewController.swift
//  AsyncDataLoader
//
//  Created by NoboPay on 17/6/19.
//  Copyright © 2019 Mostafizur. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    
    let downloader = AsyncDataLoader()
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
       print(url1)
//        "https://images.unsplash.com/photo-1464550883968-cec281c19761?ixlib=rb-0.3.5\\u0026q=80\\u0026fm=jpg\\u0026crop=entropy\\u0026s=4b142941bfd18159e2e4d166abcd0705"
        
//        let url2 = "https://images.unsplash.com/photo-1464550838636-1a3496df938b?ixlib=rb-0.3.5\\u0026q=80\\u0026fm=jpg\\u0026crop=entropy\\u0026s=ea8f203f18a51214459deec7301f177f"
//        let url3 = "https://images.unsplash.com/photo-1464547323744-4edd0cd0c746?ixlib=rb-0.3.5\\u0026q=80\\u0026fm=jpg\\u0026crop=entropy\\u0026s=17b4934ff6fe2e8773896c87aa4ae85b"
//        let url4 = "https://images.unsplash.com/photo-1464545022782-925ec69295ef?ixlib=rb-0.3.5\\u0026q=80\\u0026fm=jpg\\u0026crop=entropy\\u0026s=9af697a854378fe9e922dd8ebc6ec039"
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
        }) { (data, error) in
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
        }) { (data, error) in
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
        }) { (data, error) in
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
        }) { (data, error) in
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

