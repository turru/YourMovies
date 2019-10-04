//
//  APIRoute.swift
//  YourMovies
//
//  Created by Francisco José Gonzlález Egea on 04/10/2019.
//  Copyright © 2019 Francisco José Gonzlález Egea. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

enum NetworkError: Error {
    case failure
    case success
}

class APIRoute {
    var searchResults = [JSON]()
    let key = "apikey=dea357dd&"
    let urlApi = "http://www.omdbapi.com/?"
    let urlApiType = "type=movie&"
    let urlApiPlot = "plot=full&"
    let urlApiTypeDoc = "r=json&"

    func search(searchText: String, completionHandler: @escaping ([JSON]?, NetworkError) -> ()) {

        let urlToSearch = urlApi + key + "s=\(searchText)&" + urlApiType
        let urlString = urlToSearch.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        Alamofire.request(urlString).responseJSON { response in
            guard let data = response.data else {
                completionHandler(nil, .failure)
                return
            }

            let json = try? JSON(data: data)
            let results = json?["Search"].arrayValue
            guard let empty = results?.isEmpty, !empty else {
                completionHandler(nil, .failure)
                return
            }
            completionHandler(results, .success)
        }
    }

    func searchById(searchText: String, completionHandler: @escaping (JSON?, NetworkError) -> ()) {

        let urlToSearch = urlApi + key + "i=\(searchText)&" + urlApiType + urlApiPlot + urlApiTypeDoc
        print("urlToSearch: \(urlToSearch)")

        Alamofire.request(urlToSearch).responseJSON { response in
            guard let data = response.data else {
                completionHandler(nil, .failure)
                return
            }

            let json = try? JSON(data: data)
            let results = json
            guard let empty = results?.isEmpty, !empty else {
                completionHandler(nil, .failure)
                return
            }

            completionHandler(results, .success)
        }
    }


    func fetchImage(url: String, completionHandler: @escaping (UIImage?, NetworkError) -> ()) {

        if (!url.isValidURL) {
            completionHandler(nil, .failure)
            return
        }

        Alamofire.request(url).responseData { responseData in

            guard let imageData = responseData.data else {
                completionHandler(nil, .failure)
                return
            }

            guard let image = UIImage(data: imageData) else {
                completionHandler(nil, .failure)
                return
            }

            completionHandler(image, .success)
        }
    }
}

extension String {
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
}


