//
//  DemoCellModel.swift
//  LoginDemo
//
//  Created by Fabio Cuomo on 12/11/2018.
//  Copyright © 2018 Intelligent Apps GmbH. All rights reserved.
//

import Foundation

struct DemoCellModel: Equatable, Hashable {
    let title: String
    let description: String?
    let imagePath: String?
}

extension DemoCellModel {
    init(_ poi: POI) {
        title = String(poi.id)
        description = poi.type
        imagePath = "https://st2.depositphotos.com/7857468/12355/v/950/depositphotos_123559414-stock-illustration-cartoon-funny-yellow-taxi.jpg"
    }
}
