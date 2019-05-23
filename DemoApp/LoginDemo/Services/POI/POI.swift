//
//  GPOI.swift
//  LoginDemo
//
//  Created by Ferran Pujol Camins on 27/11/2018.
//  Copyright © 2019 Intelligent Apps GmbH. All rights reserved.
//

import Foundation

struct Coordinate: Codable, Equatable, Hashable {
    let latitude: Double
    let longitude: Double
}

struct POI: Codable, Equatable, Hashable {
    let id: Int
    let coordinate: Coordinate
    let heading: Double
    let state: String
    let type: String

//    private enum CodingKeys: String, CodingKey {
//        case title = "name"
//        case description = "house"
//        case imagePath = "imageLink"
//    }
}
