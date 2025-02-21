//
//  ImageLoaderService.swift
//  LeagueiOSChallenge
//
//  Created by macbook pro on 2025-02-20.
//

import Combine
import UIKit

protocol ImageLoaderService {
    func loadImage(path: String) -> AnyPublisher<UIImage, Error>
}

final class ImageLoader: ImageLoaderService {
    func loadImage(path: String) -> AnyPublisher<UIImage, Error> {
        guard let posterURL = URL(string: path) else {
            return Fail(error: ImageLoaderError.urlIncorrect).eraseToAnyPublisher()
        }
            return URLSession.shared.dataTaskPublisher(for: posterURL)
            .tryMap { element -> Data in
                guard let response = element.response as? HTTPURLResponse,
                      (200...299).contains(response.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return element.data
            }
            .map { UIImage(data: $0) ?? UIImage() }
            .eraseToAnyPublisher()
    }
}

enum ImageLoaderError: Error {
    case urlIncorrect
}
