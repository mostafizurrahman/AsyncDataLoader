//
//  BaseDataTask.swift
//  AsyncDataLoader
//
//  Created by NoboPay on 18/6/19.
//  Copyright © 2019 Mostafizur. All rights reserved.
//

import UIKit

protocol BaseDataTask{
    
    
    
    var completionHandler: ((Data?, Error?) -> Void)?{ get set }
    var progressHandler: ((Float) -> Void?)?{ get set }
    var cancelHandler:(()->Void?)?{ get set }
    var suspendHandler:(()->Void?)?{ get set }
    var beginingHandler:((Int64,DataType) -> Void?)?{ get set }
        func resume()
        func suspend()
        func cancel()
    
}
