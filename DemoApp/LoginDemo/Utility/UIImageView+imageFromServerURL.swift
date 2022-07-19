//
//  UIImageView+imageFromServerURL.swift
//  LoginDemo
//
//  Created by Marcin Religa on 30/6/22.
//  Copyright © 2022 Intelligent Apps GmbH. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func imageFromServerURL(_ URLString: String, placeHolder: UIImage?) {
        self.image = nil

        //If imageurl's imagename has space then this line going to work for this
        let imageServerUrl = URLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        guard let url = URL(string: imageServerUrl) else {
            return
        }

        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.image = placeHolder
                }
                return
            }
            DispatchQueue.main.async {
                if
                    let data = data,
                    let downloadedImage = UIImage(data: data)
                {
                    self.image = downloadedImage
                }
            }
        }).resume()
    }
}
