//
//  CharactersUseCase.swift
//  LoginDemo
//
//  Created by Lluís Gómez on 11/03/2019.
//  Copyright © 2019 Intelligent Apps GmbH. All rights reserved.
//

import Foundation
import RxSwift

extension UseCase {

    typealias GetAllCharacters = () -> Single<[GOTCharacter]>

    static var defaultGetAllCharacters: GetAllCharacters {
        let service: GOTServiceProtocol = DependencyRetriever.gotServiceAPI()
        return service.getAllCharacters
    }
}
