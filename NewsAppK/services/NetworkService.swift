//
//  NetworkService.swift
//  quowigeq
//
//  Created by студент on 09.10.2026.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(Int)
    case transportError(Error)
}

final class NetworkService {
    static let shared = NetworkService()
    private init() {}
    
    func fetchPosts(completion: @escaping (Result<[post], NetworkError>) -> Void) {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.transportError(error)))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                completion(.failure(.serverError(httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let posts = try JSONDecoder().decode([post].self, from: data)
                completion(.success(posts))
            } catch {
                completion(.failure(.decodingError))
            }
        }.resume()
    }
}
