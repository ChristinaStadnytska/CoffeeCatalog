//
//  NetworkService.swift
//  CoffeeCatalog
//
//  Created by Christina Stadnytska on 08.07.2026.
//

import Foundation
import Combine

enum NetworkError: Error {
    case invalidURL
    case badResponse(statusCode: Int)
    case decodingFailed(Error)
    case transport(Error)
}

protocol NetworkServiceInterface {
    func fetchCoffeeList(category: CoffeeCategory) async throws -> [CoffeeModel]
}

final class NetworkService: NetworkServiceInterface {
    func fetchCoffeeList(category: CoffeeCategory) async throws -> [CoffeeModel] {
        guard let url = URL(string: "https://api.sampleapis.com/coffee/\(category.rawValue)") else {
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
    
    private func fetchFullMenu(completion: @escaping ([CoffeeModel], Error?) -> Void) {
        var hotCoffees = [CoffeeModel]()
        var icedCoffees = [CoffeeModel]()
        var fetchError: Error?
        
        let group = DispatchGroup()
        group.enter()
        fetchOne(category: .hot) { result in
            switch result {
            case .success(let coffees): hotCoffees = coffees
            case .failure(let error): fetchError = error
            }
            group.leave()
        }
        
        group.enter()
        fetchOne(category: .iced) { result in
            switch result {
            case .success(let coffees): icedCoffees = coffees
            case .failure(let error): fetchError = error
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            completion(hotCoffees + icedCoffees, fetchError)
        }
    }
    
    func fetchFullMenuPublisher() -> AnyPublisher<[CoffeeModel], Never> {
        Publishers.MergeMany([fetchOnePublisher(category: .hot), fetchOnePublisher(category: .iced)])
            .collect()
            .map { pages in pages.flatMap { $0 } }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    func fetchFullMenuAsync() async throws -> [CoffeeModel] {
        async let hot = fetchCoffeeList(category: .hot)
        async let iced = fetchCoffeeList(category: .iced)
        return try await hot + iced
    }
    
    private func fetchOne(category: CoffeeCategory, completion: @escaping (Result<[CoffeeModel], Error>) -> Void) {
        guard let url = URL(string: "https://api.sampleapis.com/coffee/\(category.rawValue)") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.badResponse(statusCode: -1)))
                return
            }
            guard (200...209).contains(httpResponse.statusCode), let data else {
                completion(.failure(NetworkError.badResponse(statusCode: httpResponse.statusCode)))
                return
            }
            
            do {
                let coffees = try JSONDecoder().decode([CoffeeModel].self, from: data)
                completion(.success(coffees))
            } catch {
                completion(.failure(NetworkError.decodingFailed(error)))
            }
        }.resume()
    }
    
    private func fetchOnePublisher(category: CoffeeCategory) -> AnyPublisher<[CoffeeModel], Error> {
        guard let url = URL(string: "https://api.sampleapis.com/coffee/\(category.rawValue)") else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [CoffeeModel].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
