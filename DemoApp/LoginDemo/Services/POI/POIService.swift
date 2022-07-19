//
//  POIService.swift
//  LoginDemo
//
//  Created by Fabio Cuomo on 13/11/2018.
//  Copyright © 2019 Intelligent Apps GmbH. All rights reserved.
//

import Foundation
import RxSwift

protocol POIServiceProtocol {
    func getAllPois() -> Single<[POI]>
}

final class POIService: POIServiceProtocol {
    
    private let url = "https://poi-api.mytaxi.com/PoiService/poi/v1"

    private var getPOIURLRequest: URLRequest? {
        var urlComponents = URLComponents(string: url)
        urlComponents?.queryItems = [
            URLQueryItem(name: "p1Lat", value: "53.694865"),
            URLQueryItem(name: "p1Lon", value: "9.757589"),
            URLQueryItem(name: "p2Lat", value: "53.394655"),
            URLQueryItem(name: "p2Lon", value: "10.099891")
        ]

        guard let url = urlComponents?.url else {
            return nil
        }

        return URLRequest(url: url)
    }

    func getAllPois(completion: @escaping (APIResult<[POI]>) -> Void) {
        guard let getPOIURLRequest = getPOIURLRequest else {
            return
        }

        URLSession.shared.dataTask(with: getPOIURLRequest) { data, urlResponse, error in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let pois = try decoder.decode([String: [POI]].self, from: data)
                    completion(APIResult.success(POIService.randomArray(from: pois.values.joined())))
                } catch {
                    let result: APIResult<[POI]> = .error(.serverError)
                    completion(result)
                }
            }
        }.resume()
    }
    
    func getAllPois() -> Single<[POI]> {
        return Single
            .create { [weak self] observer in
                self?.getAllPois() { result in
                    switch result {
                    case .success(let pois):
                        return observer(.success(pois))
                    case .error(let error):
                        return observer(.error(error))
                    }
                }
                return Disposables.create()
        }
    }

    private static func randomArray<C: Collection>(from collection: C) -> [C.Element] {
        let shuffled = collection.shuffled()
        let n = Int.random(in: 1...50)
        return Array(shuffled[..<n])
    }
    
}
