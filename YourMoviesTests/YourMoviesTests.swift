//
//  YourMoviesTests.swift
//  YourMoviesTests
//
//  Created by Francisco José Gonzlález Egea on 04/10/2019.
//  Copyright © 2019 Francisco José Gonzlález Egea. All rights reserved.
//

import XCTest
@testable import YourMovies
import SwiftyJSON
import Alamofire

class YourMoviesTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }



    func textSearchMovieWitSpace() throws {
        let urlToSearch = "http://www.omdbapi.com/?apikey=dea357dd&s=guardianes&"
        let api = APIRoute()
        api.search(searchText: urlToSearch, completionHandler: {
        results, error in
        if case .failure = error {
            XCTFail("No data in response")
            return

            }

        })
        XCTAssert(true)

    }



//
//    func testExample() {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }
//
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
