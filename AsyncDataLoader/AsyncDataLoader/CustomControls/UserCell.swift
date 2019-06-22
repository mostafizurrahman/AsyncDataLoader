//
//  UserCell.swift
//  AsyncDataLoader
//
//  Created by Mostafizur Rahman on 22/6/19.
//  Copyright © 2019 Mostafizur. All rights reserved.
//

import UIKit

class UserCell: UICollectionViewCell {
    @IBOutlet weak var userPicture: UIImageView!
    @IBOutlet weak var errorTxt: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var circleProgress: CircularProgress!
}
