//
//  POIService.swift
//  LoginDemo
//
//  Created by Fabio Cuomo on 13/11/2018.
//  Copyright © 2019 Intelligent Apps GmbH. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

protocol POIServiceProtocol {
    func getAllPois() -> Single<[POI]>
}

final class POIService: POIServiceProtocol {

    private let url = "https://poi-api.mytaxi.com/PoiService/poi/v1"
    func getAllPois(completion: @escaping (APIResult<[POI]>) -> Void) {
        AF.request(url, parameters: ["p1Lat":53.694865, "p1Lon":9.757589, "p2Lat":53.394655, "p2Lon":10.099891])
            .responseData { (response) in
                if let data = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let pois = try decoder.decode([String: [POI]].self, from: data)
                        completion(APIResult.success(POIService.randomArray(from: pois.values.joined())))
                    } catch {
                        let result: APIResult<[POI]> = .error(.serverError)
                        completion(result)
                    }
                }
            }
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
