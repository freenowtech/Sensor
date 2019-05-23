//
//  PoisUseCase.swift
//  LoginDemo
//
//  Created by Lluís Gómez on 11/03/2019.
//  Copyright © 2019 Intelligent Apps GmbH. All rights reserved.
//

import UIKit
import RxSwift

extension UseCase {

    typealias MakePoiListVc = () -> UIViewController

    static func defaultMakePoiListVc() -> MakePoiListVc {
        return {
            return DemoTableViewController()
        }
    }

    typealias GetAllPois = () -> Single<[POI]>

    static var defaultGetAllPois: GetAllPois {
        let service: POIServiceProtocol = DependencyRetriever.poiServiceAPI()
        return service.getAllPois
    }
}
