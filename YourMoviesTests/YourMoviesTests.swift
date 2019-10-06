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

    let m_urlToSearch = "http://www.omdbapi.com/?apikey=dea357dd&s=guardianes&"
    var m_api = APIRoute()

    func testAlomofireSearchByTitle() throws {

        let _expectation = self.expectation(description: "Alamofire")
        Alamofire.request(m_urlToSearch, method: .get, parameters: nil, encoding: JSONEncoding.default, headers:          nil).validate().responseJSON { (response) in

            switch response.result {
            case .success:
                if let data = response.data {
                    let json = try? JSON(data: data)
                    let results = json?["Search"].arrayValue
                    if let empty = results?.isEmpty, !empty  {
                        XCTAssert(results!.count > 0)
                    }
                }
            case .failure(let error):
                XCTFail("No data in response")
                print(error)
                return
            }
            _expectation.fulfill()
        }
        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testAPIRouteSearchByTitleAPIRouteWithoutSpaces()  {

        let _expectation = self.expectation(description: "APIRoute")

        m_api.search(searchText: "incredibles", completionHandler: { results, error in

            switch error {
            case .success:
                XCTAssert(error == .success)
            case .failure:
                XCTFail("No data in response")
            }

            _expectation.fulfill()
        })
        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testAPIRouteSearchByTitleAPIRouteWithSpaces()  {

        let textToSearch = "The incredibles"
        let _expectation = self.expectation(description: "APIRoute")

        m_api.search(searchText: textToSearch, completionHandler: { results, error in

            switch error {
            case .success:
                XCTAssert(results!.count > 0)
//                print("------- examples: \(String(describing: results))")
            case .failure:
                XCTFail("No data in response")
            }
            _expectation.fulfill()
        })
        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testAPIRouteSearchByTitleAPIRouteWithoutResults()  {

        let textToSearch = "lalalalalalaa"
        let _expectation = self.expectation(description: "APIRoute")

        m_api.search(searchText: textToSearch, completionHandler: { results, error in

            switch error {
            case .success:
                XCTAssert(results!.count > 0)
                XCTFail("Results is almost 1")
            case .failure:
                XCTAssertNil(results)

            }
            _expectation.fulfill()
        })
        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testAPIRouteSearchByIDPIRoute()  {

        // the incredibles with id: tt0317705
        let textToSearch = "tt0317705"
        let _expectation = self.expectation(description: "APIRoute")

        m_api.searchById(searchText: textToSearch, completionHandler: { results, error in

            switch error {
            case .success:
                XCTAssertNotNil(results)
            case .failure:
                XCTFail("No data in response")
            }
            _expectation.fulfill()
        })
        waitForExpectations(timeout: 5.0, handler: nil)
    }

}
