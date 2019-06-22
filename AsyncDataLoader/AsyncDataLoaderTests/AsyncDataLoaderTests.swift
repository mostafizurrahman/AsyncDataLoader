//
//  AsyncDataLoaderTests.swift
//  AsyncDataLoaderTests
//
//  Created by NoboPay on 17/6/19.
//  Copyright © 2019 Mostafizur. All rights reserved.
//

import XCTest
@testable import AsyncDataLoader

class AsyncDataLoaderTests: XCTestCase {

    var blockDownloader = AsyncBlockDownloader()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
//        self.blockDownloader = nil
        super.tearDown()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    
    func testBlockDownload(){
        //download an image and test
        if let url = AppDelegate.jsonarray[0]["urls"].dictionaryValue["full"]?.stringValue {
            let data_size = 286269
            self.blockDownloader.download(From: url, beginHandler: { (_data_size, _type) in
                XCTAssert(data_size == _data_size, "Test failed in begin block for wrong image data size returned")
                XCTAssert(_type == DataType.image, "Test failed in begin block for wrong content type returned")
            }, progressHandler: { (_percent) in
                XCTAssert(_percent >= 0 && _percent <= 1, "Test failed in progress block for wrong download completed percentage returned")
            }, cancelHandler: {
                
            }, identifier: { (idf) in
                
            }) { (data, type, error) in
                XCTAssert(type == DataType.image, "Test failed in begin block for wrong content type returned")
                XCTAssert(data?.count == data_size, "Test failed in begin block for wrong content type returned")
            }
        }
    }
    
    func testGetRequest(){
        if let url = AppDelegate.jsonarray[0]["urls"].dictionaryValue["full"]?.stringValue {
            let req =  self.blockDownloader.getRequest(From: url)
            XCTAssert(req != nil, "Request returned by downloader is nil")
        }
    }
    
    func testCacelAllDownloads(){
        if let url = self.startDownloads() {
            let task_inner = self.blockDownloader.cancelAllDownloads(ForUrl: url)
            XCTAssert(task_inner != nil, "Download cancelation failed")
            return
        }
        XCTAssert(false, "Fail to cancel download")
    }
    
    func startDownloads()->String?{
        if let url =  AppDelegate.jsonarray[3]["urls"].dictionaryValue["full"]?.stringValue {
            self.blockDownloader.download(From: url, beginHandler: { (_data_size, _type) in
                
            }, progressHandler: { (_percent) in
                
            }, cancelHandler: {
                
            }, identifier: { (idf) in
                
            }) { (data, type, error) in
                
            }
            return url
        }
        return nil
    }
}
