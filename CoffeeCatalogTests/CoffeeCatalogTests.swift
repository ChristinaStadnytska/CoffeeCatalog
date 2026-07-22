//
//  CoffeeCatalogTests.swift
//  CoffeeCatalogTests
//
//  Created by Christina Stadnytska on 03.07.2026.
//

import Testing
@testable import CoffeeCatalog

struct CoffeeCatalogTests {

    @Test @MainActor
    func fetchCoffeeList_success_updatesCoffees() async throws {
        let modelLatte = CoffeeModel(title: "Latte")
        let modelEspresso = CoffeeModel(title: "Espresso")
        let mockService = MockNetworkService()
        mockService.resultToReturn = [modelLatte, modelEspresso]
        let viewModel = CoffeeListViewModel(coffees: [], service: mockService)
        
        await viewModel.getCoffeeList()
        
        #expect(viewModel.viewState == .loaded)
        #expect(viewModel.coffees == [modelLatte, modelEspresso])
    }
    
    @Test @MainActor
    func fetchCoffeeList_failure_setsErrorState() async throws {
        let mockService = MockNetworkService()
        mockService.errorToThrow = NetworkError.invalidURL
        let viewModel = CoffeeListViewModel(coffees: [], service: mockService)
        
        await viewModel.getCoffeeList()
        
        if case .error = viewModel.viewState {
            #expect(viewModel.coffees.isEmpty)
        } else {
            Issue.record("Expected .error state")
        }
    }
}
