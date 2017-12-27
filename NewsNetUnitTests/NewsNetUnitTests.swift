//
//  NewsNetUnitTests.swift
//  NewsNetUnitTests
//
//  Created by Genaro Codina Reverter on 27/12/2017.
//  Copyright © 2017 Genaro Codina Reverter. All rights reserved.
//

import XCTest
@testable import NewsNet

class NewsNetUnitTests: XCTestCase {
    
    var sessionUnderTest: URLSession!
    private let basePath = "https://newsapi.org/v1"
    //
    // Go to https://newsapi.org/register to get your
    // free API key, and then replace your key in the
    // following constant
    //
    private let key = "fed53a58581641b49024dc6bc854db8c"
    
    override func setUp() {
        
        super.setUp()
        sessionUnderTest = URLSession(configuration: URLSessionConfiguration.default)
    }
    
    override func tearDown() {
        
        sessionUnderTest = nil
        super.tearDown()
    }
    
    func testGetNewspapersCompletes() {
        
        let url = URL(string:"\(basePath)/sources")
        
        // expectation(_:) returns an XCTestExpectation object, which you store in promise.
        // Other commonly used names for this object are expectation and future.
        // The description parameter describes what you expect to happen.
        let promise = expectation(description: "Completion handler invoked")
        var statusCode: Int?
        var responseError: Error?
        
        // when
        let dataTask = sessionUnderTest.dataTask(with: url!) { data, response, error in
            statusCode = (response as? HTTPURLResponse)?.statusCode
            responseError = error
            // To match the description, it is called promise.fulfill()
            // in the success condition closure of the asynchronous method’s completion handler.
            promise.fulfill()
        }
        dataTask.resume()
        // keeps the test running until all expectations are fulfilled, or the timeout interval ends, whichever happens first.
        waitForExpectations(timeout: 5, handler: nil)
        
        // then
        XCTAssertNil(responseError)
        XCTAssertEqual(statusCode, 200)
    }
    
    func testGetBBCArticlesCompletes() {
        
        let url = URL(string:"\(basePath)/articles?source=bbc-news&apiKey=\(key)")
        
        // expectation(_:) returns an XCTestExpectation object, which you store in promise.
        // Other commonly used names for this object are expectation and future.
        // The description parameter describes what you expect to happen.
        let promise = expectation(description: "Completion handler invoked")
        var statusCode: Int?
        var responseError: Error?
        
        // when
        let dataTask = sessionUnderTest.dataTask(with: url!) { data, response, error in
            statusCode = (response as? HTTPURLResponse)?.statusCode
            responseError = error
            // To match the description, it is called promise.fulfill()
            // in the success condition closure of the asynchronous method’s completion handler.
            promise.fulfill()
        }
        dataTask.resume()
        // keeps the test running until all expectations are fulfilled, or the timeout interval ends, whichever happens first.
        waitForExpectations(timeout: 5, handler: nil)
        
        // then
        XCTAssertNil(responseError)
        XCTAssertEqual(statusCode, 200)
    }
}
