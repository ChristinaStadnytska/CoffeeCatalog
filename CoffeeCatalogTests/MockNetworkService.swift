//
//  MockNetworkService.swift
//  CoffeeCatalogTests
//
//  Created by Christina Stadnytska on 17.07.2026.
//

import Foundation
@testable import CoffeeCatalog

final class MockNetworkService: NetworkServiceInterface {
    var resultToReturn: [CoffeeModel] = []
    var errorToThrow: Error?
    
    func fetchCoffeeList() async throws -> [CoffeeModel] {
        guard let errorToThrow else { return resultToReturn }
        throw errorToThrow
    }
}
