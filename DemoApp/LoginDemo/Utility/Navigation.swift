//
//  Navigation.swift
//  LoginDemo
//
//  Created by Adrian Zdanowicz on 18/04/2019.
//  Copyright © 2019 Mounir Dellagi. All rights reserved.
//

import Foundation

// All navigation states, new should be added when needed.

enum Navigation {
    case detail(POI)
    case dismiss
    case login
    case pop
    case showError
}
