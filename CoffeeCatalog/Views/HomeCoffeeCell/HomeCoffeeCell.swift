//
//  HomeCoffeeCell.swift
//  CoffeeCatalog
//
//  Created by Christina Stadnytska on 03.07.2026.
//

import SwiftUI

struct HomeCoffeeCell: View {
    @State private var isPresented = false
    let coffeeItem: CoffeeModel
    let onItemTapped: () -> Void
    let onUpdateItemTapped: (CoffeeModel) -> Void
    let onFavouriteTapped: (CoffeeModel) -> Void

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading) {
                Text(coffeeItem.title)
                    .font(.title)
                    .bold()
                if let coffeeDescription = coffeeItem.description {
                    Text(coffeeDescription)
                        .font(.subheadline)
                        .italic()
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            .padding()
            Spacer()

            CoffeeImageView(imageURLString: coffeeItem.image)
                .frame(width: 60.0, height: 60.0)
            
            HStack {
                Button {
                    onFavouriteTapped(coffeeItem)
                } label: {
                    Image(systemName: coffeeItem.favourite ? "heart.fill" : "heart")
                        .foregroundStyle(.brown)
                }
                Button("", systemImage: "pencil") {
                    isPresented = true
                }
                .foregroundStyle(.brown)

                Image(systemName: "arrowshape.right.fill")
                    .foregroundStyle(.brown)
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .background(Color.yellow.opacity(0.3))
        .cornerRadius(12.0)
        .padding(.vertical, 6.0)
        .padding(.horizontal, 16.0)
        .onTapGesture { onItemTapped() }
        .sheet(isPresented: $isPresented) {
            AddCoffeeView(coffee: coffeeItem) { item in
                onUpdateItemTapped(item)
            }
        }
    }
}

#Preview {
    let testCoffeeItem: CoffeeModel = .init(title: "Latte", description: "Description", ingredients: nil, image: nil, favourite: false)
    HomeCoffeeCell(coffeeItem: testCoffeeItem, onItemTapped: {}, onUpdateItemTapped: {_ in }, onFavouriteTapped: {_ in })
}
