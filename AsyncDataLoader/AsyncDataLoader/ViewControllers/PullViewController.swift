//
//  PullViewController.swift
//  AsyncDataLoader
//
//  Created by Mostafizur Rahman on 22/6/19.
//  Copyright © 2019 Mostafizur. All rights reserved.
//

import UIKit

class PullViewController: UIViewController {

    @IBOutlet weak var userCollectionView: UICollectionView!
    var refreshControl = UIRefreshControl()
    let blockDownloader = AsyncBlockDownloader()
    let delegateDownloader = AsyncInterfaceDownloader()
    var jsonArray:[JSON] = []
    var jsonDownloadKey = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl.attributedTitle = NSAttributedString(string: "Loading new data....")
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: UIControl.Event.valueChanged)
        self.userCollectionView.addSubview(refreshControl)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width / 2 - 30, height: 200)
        layout.sectionInset = UIEdgeInsets(top:10 , left: 10,
                                           bottom: 10, right: 10)
        layout.minimumLineSpacing = 10
        self.userCollectionView.collectionViewLayout = layout
        self.refresh(UIButton())
        // Do any additional setup after loading the view.
    }
    
    @objc func refresh(_ sender:AnyObject) {
        // Code to refresh table viewre
        _ = CacheManager.shared.removeCache(ForKey: "http://pastebin.com/raw/wgkJgazE")
       let (key,_,_) = self.delegateDownloader.download(FromPath: "http://pastebin.com/raw/wgkJgazE",
                                         DelegateTo: self)
        self.jsonDownloadKey = key ?? ""
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


extension PullViewController:UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.jsonArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let userCell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserCell", for: indexPath) as! UserCell
        let user = self.jsonArray[indexPath.row]["user"].dictionaryValue
        let name = user["name"] // user["name"]?.stringValue
        userCell.userName.text = name?.string
        userCell.errorTxt.isHidden = true
        if let url =  user["profile_image"]?.dictionaryValue["large"]?.stringValue {
            
            self.blockDownloader.download(From: url, beginHandler: { (_, _) in
                
            }, progressHandler: { (percent) in
                userCell.circleProgress.isHidden = false
                userCell.circleProgress.setProgressWithAnimation(duration: 0, value: percent)
            }, cancelHandler: {
                
            }, identifier: { (_) in
                
            }) { (_data, _, error) in
                userCell.circleProgress.isHidden = true
                if let _ = error {
                    userCell.errorTxt.text = "Data not found in the specified url"
                } else if let data = _data {
                    let image = UIImage(data: data)
                    userCell.userPicture.image = image
                }
            }
        }
    
        return userCell
    }
    
    
}

extension PullViewController : DownloadCompletionDelegate{
    func didDownloadCompleted(ForID downloadID: String, Data data: Data?,
                              Type type: DataType?, Error error: Error?) {
        if self.jsonDownloadKey.elementsEqual(downloadID) ,
            let _data = data {
            let jsonData = JSON(data: _data)
            self.jsonArray = jsonData.arrayValue
            self.userCollectionView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    func didDownloadCanceled(ForID downloadID: String) {
        self.refreshControl.endRefreshing()
    }
    
    func onCompleted(Parcentage percent: Float, ForID downloadID: String) {
        
    }
    
    func willBeginDownload(WithSize size: Int64, Type type: DataType, ForID downloadID: String) {
        
    }
    
    func didDownloadSuspended(ForID downloadID: String) {
        
    }
    
    
}
