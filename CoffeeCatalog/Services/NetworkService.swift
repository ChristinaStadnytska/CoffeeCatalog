//
//  NetworkService.swift
//  CoffeeCatalog
//
//  Created by Christina Stadnytska on 08.07.2026.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case badResponse(statusCode: Int)
    case decodingFailed(Error)
    case transport(Error)
}

protocol NetworkServiceInterface {
    func fetchCoffeeList() async throws -> [CoffeeModel]
}

final class NetworkService: NetworkServiceInterface {
    func fetchCoffeeList() async throws -> [CoffeeModel] {
        guard let url = URL(string: "https://api.sampleapis.com/coffee/hot") else {
            throw NetworkError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.badResponse(statusCode: -1)
            }
            guard (200...209).contains(httpResponse.statusCode) else {
                throw NetworkError.badResponse(statusCode: httpResponse.statusCode)
            }
            
            do {
                return try JSONDecoder().decode([CoffeeModel].self, from: data)
            } catch {
                throw NetworkError.decodingFailed(error)
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.transport(error)
        }
    }
}
