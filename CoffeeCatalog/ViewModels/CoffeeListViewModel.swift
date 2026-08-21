//
//  CoffeeListViewModel.swift
//  CoffeeCatalog
//
//  Created by Christina Stadnytska on 07.07.2026.
//

import Foundation
import Combine

enum CoffeeListViewState: Equatable {
    case `default`
    case loading
    case loaded
    case error(String)
}

@Observable final class CoffeeListViewModel {
    var coffees: [CoffeeModel]
    var viewState: CoffeeListViewState = .default
    var searchText = "" {
        didSet {
            searchSubject.send(searchText)
        }
    }
    var displayedCoffees: [CoffeeModel] {
        debouncedSearchText.isEmpty ? coffees : coffees.filter { $0.title.localizedCaseInsensitiveContains(debouncedSearchText) }
    }
    private var debouncedSearchText = ""
    private let searchSubject = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()
    private let service: NetworkServiceInterface

    init(coffees: [CoffeeModel],
         service: NetworkServiceInterface = NetworkService()) {
        self.coffees = coffees
        self.service = service
        searchSubject
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] query in
                self?.debouncedSearchText = query
            }
            .store(in: &cancellables)
    }

    @MainActor
    func getCoffeeList() async {
        guard viewState != .loaded else { return }
        
        viewState = .loading
        do {
            coffees = try await service.fetchCoffeeList(category: .hot)
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
