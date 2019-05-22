//
//  DemoCellModel.swift
//  LoginDemoRxRedux
//
//  Created by Fabio Cuomo on 12/11/2018.
//  Copyright © 2018 Mounir Dellagi. All rights reserved.
//

import Foundation

struct DemoCellModel: Equatable, Hashable {
    let title: String
    let description: String?
    let imagePath: String?
}

extension DemoCellModel {
    init(_ character: GOTCharacter) {
        title = character.title
        description = character.description
        imagePath = character.imagePath
    }
}
