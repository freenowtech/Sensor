//
//  RandomColorUseCase.swift
//  LoginDemo
//
//  Created by Adrian Zdanowicz on 07/05/2019.
//  Copyright © 2019 Intelligent Apps GmbH. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

extension UseCase {
    
    typealias GetRandomColor = () -> Single<UIColor>
    
    static func getRandomColor() -> GetRandomColor {
        return {
            return Single.just(UIColor(red:   randomCGFloat(),
                           green: randomCGFloat(),
                           blue:  randomCGFloat(),
                           alpha: 1.0))
        }
    }
    
    private static func randomCGFloat() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
    
}

