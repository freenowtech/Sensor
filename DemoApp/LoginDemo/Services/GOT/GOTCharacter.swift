//
//  GOTCharacter.swift
//  LoginDemo
//
//  Created by Ferran Pujol Camins on 27/11/2018.
//  Copyright © 2019 Intelligent Apps GmbH. All rights reserved.
//

import Foundation

struct GOTCharacter: Codable, Equatable, Hashable {
    let title: String
    let description: String?
    let imagePath: String?

    private enum CodingKeys: String, CodingKey {
        case title = "name"
        case description = "house"
        case imagePath = "imageLink"
    }
}
