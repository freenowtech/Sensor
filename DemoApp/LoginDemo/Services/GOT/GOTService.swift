//
//  GOTService.swift
//  LoginDemo
//
//  Created by Fabio Cuomo on 13/11/2018.
//  Copyright © 2019 Intelligent Apps GmbH. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

protocol GOTServiceProtocol {
    func getAllCharacters() -> Single<[GOTCharacter]>
}

final class GOTService: GOTServiceProtocol {
    
    private let url = "https://api.got.show/api/characters/"
    
    func getAllCharacters(completion: @escaping (APIResult<[GOTCharacter]>) -> Void) {
        Alamofire.request(url).responseData { (response) in
            if let data = response.result.value {
                do {
                    let decoder = JSONDecoder()
                    let characters = try decoder.decode([GOTCharacter].self, from: data)
                    completion(APIResult.success(self.randomArray(from: characters)))
                } catch {
                    let result: APIResult<[GOTCharacter]> = .error(.serverError)
                    completion(result)
                }
            }
        }
    }
    
    func getAllCharacters() -> Single<[GOTCharacter]> {
        return Single
            .create { [weak self] observer in
                self?.getAllCharacters() { result in
                    switch result {
                    case .success(let characters):
                        return observer(.success(characters))
                    case .error(let error):
                        return observer(.error(error))
                    }
                }
                return Disposables.create()
        }
    }

    private func randomArray<T>(from array: [T]) -> [T] {
        let shuffledArray = array.shuffled()
        let n = Int.random(in: 1...50)
        return Array(shuffledArray[..<n])
    }
    
}
