//
//  HomeCoffeeDetailView.swift
//  CoffeeCatalog
//
//  Created by Christina Stadnytska on 03.07.2026.
//

import SwiftUI

struct HomeCoffeeDetailView: View {
    let coffeeItem: CoffeeModel
    
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
            Spacer()
        }
        .padding()
        .navigationTitle(coffeeItem.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let testCoffeeItem: CoffeeModel = .init(title: "Latte", description: "Description", ingredients: nil, image: nil, favourite: false)
    HomeCoffeeDetailView(coffeeItem: testCoffeeItem)
}
