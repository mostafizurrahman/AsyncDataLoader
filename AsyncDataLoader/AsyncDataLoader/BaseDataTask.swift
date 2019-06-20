//
//  BaseDataTask.swift
//  AsyncDataLoader
//
//  Created by NoboPay on 18/6/19.
//  Copyright © 2019 Mostafizur. All rights reserved.
//

import UIKit

protocol BaseDataTask{
    
    
    
    var completionHandlers: [((Data?, DataType?, Error?) -> Void)?]{ get set }
    var progressHandlers:[ ((Float) -> Void?)?]{ get set }
    var cancelHandlers:[(()->Void?)?]{ get set }
    var suspendHandlers:[(()->Void?)?]{ get set }
    var beginingHandlers:[((Int64,DataType) -> Void?)?]{ get set }
        func resume()
        func suspend()
        func cancel()
    
}
