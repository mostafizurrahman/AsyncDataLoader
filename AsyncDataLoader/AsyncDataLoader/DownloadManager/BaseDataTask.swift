//
//  BaseDataTask.swift
//  AsyncDataLoader
//
//  Created by NoboPay on 18/6/19.
//  Copyright © 2019 Mostafizur. All rights reserved.
//

import UIKit

protocol BaseDataTask{
    
    
    var completionHandlers: [String : ((Data?, DataType?, Error?) -> Void)?]{ get set }
    var progressHandlers:[String :  ((Float) -> Void?)?]{ get set }
    var cancelHandlers:[String : (()->Void?)?]{ get set }
    var beginingHandlers:[String : ((Int64,DataType) -> Void?)?]{ get set }
        func resume()
        func suspend()
        func cancel()
    
}
