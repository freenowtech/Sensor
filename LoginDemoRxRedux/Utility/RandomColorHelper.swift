//
//  RandomColorHelper.swift
//  LoginDemoRxRedux
//
//  Created by Fabio Cuomo on 13/11/2018.
//  Copyright © 2018 Mounir Dellagi. All rights reserved.
//

import UIKit

final class RandomColorHelper {
    static let palette = [
        UIColor(red: 136/255, green: 100/255, blue: 86/255, alpha: 1),
        UIColor(red: 214/255, green: 148/255, blue: 97/255, alpha: 1),
        UIColor(red: 146/255, green: 151/255, blue: 49/255, alpha: 1),
        UIColor(red: 118/255, green: 109/255, blue: 50/255, alpha: 1),
        UIColor(red: 82/255, green: 90/255, blue: 42/255, alpha: 1)
    ]

    static func randomColorFromPalette() -> UIColor {
        let idx: Int = Int(arc4random_uniform(UInt32(palette.count - 1)))
        return palette[idx]
    }
}
