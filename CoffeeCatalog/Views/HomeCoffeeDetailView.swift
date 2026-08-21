//
//  HomeCoffeeDetailView.swift
//  CoffeeCatalog
//
//  Created by Christina Stadnytska on 03.07.2026.
//

import SwiftUI

struct HomeCoffeeDetailView: View {
    private let coffeeItem: CoffeeModel
    @State private var isFavourite: Bool
    let onFavouriteTapped: (CoffeeModel) -> Void
    
    init(coffeeItem: CoffeeModel,
         onFavouriteTapped: @escaping (CoffeeModel) -> Void) {
        self.coffeeItem = coffeeItem
        self.onFavouriteTapped = onFavouriteTapped
        _isFavourite = State(initialValue: coffeeItem.favourite)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            CoffeeImageView(imageURLString: coffeeItem.image)
                .frame(width: 200.0, height: 200.0)
            
            Text(coffeeItem.title)
                .font(.largeTitle)
                .bold()
            
            if let coffeeDescription = coffeeItem.description {
                Text(coffeeDescription)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Toggle("Is it your favourite?", isOn: $isFavourite)
                .onChange(of: isFavourite, { _, _ in
                    onFavouriteTapped(coffeeItem)
                })
                .padding()
            Spacer()
        }
        .padding()
        .navigationTitle(coffeeItem.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let testCoffeeItem: CoffeeModel = .init(title: "Latte", description: "Description", ingredients: nil, image: nil, favourite: false)
    HomeCoffeeDetailView(coffeeItem: testCoffeeItem, onFavouriteTapped: {_ in})
}
