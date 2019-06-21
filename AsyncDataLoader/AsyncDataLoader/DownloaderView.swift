//
//  DownloaderView.swift
//  AsyncDataLoader
//
//  Created by Mostafizur Rahman on 21/6/19.
//  Copyright © 2019 Mostafizur. All rights reserved.
//

import UIKit

class DownloaderView: UIView {

    var downloadIdentifier:String?
    var remoteUrl:String?
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var percentIndicator: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var circleProgress: CircularProgress!
    @IBOutlet weak var imageView: UIImageView!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
