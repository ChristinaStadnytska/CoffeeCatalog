//
//  CoffeeListViewModel.swift
//  CoffeeCatalog
//
//  Created by Christina Stadnytska on 07.07.2026.
//

import Foundation
internal import Combine

enum CoffeeListViewState: Equatable {
    case `default`
    case loading
    case loaded
    case error(String)
}

final class CoffeeListViewModel: ObservableObject {
    @Published var coffees: [CoffeeModel]
    @Published var viewState: CoffeeListViewState = .default
    private let service: NetworkServiceInterface

    init(coffees: [CoffeeModel],
         service: NetworkServiceInterface = NetworkService()) {
        self.coffees = coffees
        self.service = service
    }

    @MainActor
    func getCoffeeList() async {
        guard viewState != .loaded else { return }
        
        viewState = .loading
        do {
            coffees = try await service.fetchCoffeeList()
            viewState = .loaded
        } catch {
            viewState = .error(error.localizedDescription)
        }
    }

    func updateCoffeeList(item: CoffeeModel) {
        if let index = coffees.firstIndex(where: { $0.id == item.id }) {
            coffees[index] = item
        } else {
            coffees.append(item)
        }
    }

    func removeCoffee(item: CoffeeModel) {
        coffees.removeAll { $0.id == item.id }
    }
    
    func toggleFavourite(item: CoffeeModel) {
        guard let index = coffees.firstIndex(where: { $0.id == item.id }) else { return }
        coffees[index].favourite.toggle()
    }
}
