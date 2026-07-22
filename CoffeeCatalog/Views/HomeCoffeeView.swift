//
//  HomeCoffeeView.swift
//  CoffeeCatalog
//
//  Created by Christina Stadnytska on 03.07.2026.
//

import SwiftUI

struct HomeCoffeeView: View {
    @StateObject var viewModelCoffee = CoffeeListViewModel(coffees: [])
    @State private var path = NavigationPath()
    @State private var isPresentedAdding = false
    
    @ViewBuilder
    private var content: some View {
        switch viewModelCoffee.viewState {
        case .default, .loading:
            ProgressView()
        case .loaded:
            ScrollView {
                LazyVStack(spacing: 16.0) {
                    ForEach(viewModelCoffee.coffees) { coffee in
                        HomeCoffeeCell(coffeeItem: coffee) {
                            path.append(coffee)
                        } onUpdateItemTapped: { item in
                            viewModelCoffee.updateCoffeeList(item: item)
                        } onFavouriteTapped: { item in
                            viewModelCoffee.toggleFavourite(item: item)
                        }
                    }
                }
            }
        case .error(let message):
            VStack {
                Text(message)
                Button("Try again") {
                    Task {
                        await viewModelCoffee.getCoffeeList()
                    }
                }
            }
        }
    }

    var body: some View {
        NavigationStack(path: $path) {
            content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toolbar(content: {
                Button("", systemImage: "plus.circle") {
                    isPresentedAdding = true
                }
            })
            .sheet(isPresented: $isPresentedAdding, content: {
                AddCoffeeView { item in
                    viewModelCoffee.updateCoffeeList(item: item)
                }
            })
            .navigationDestination(for: CoffeeModel.self) { route in
                HomeCoffeeDetailView(coffeeItem: route)
            }
            .navigationTitle("Coffee List")
            .task {
                await viewModelCoffee.getCoffeeList()
            }
        }
    }
}

#Preview {
    let testCoffeeItem: CoffeeModel = .init(title: "Latte", description: "Description", ingredients: nil, image: nil, favourite: false)
    HomeCoffeeView(viewModelCoffee: .init(coffees: [testCoffeeItem]))
}
