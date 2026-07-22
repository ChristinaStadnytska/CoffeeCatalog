//
//  AddCoffeeView.swift
//  CoffeeCatalog
//
//  Created by Christina Stadnytska on 07.07.2026.
//

import SwiftUI

struct AddCoffeeView: View {
    @State private var title: String
    @State private var description: String
    @State private var isFavourite: Bool
    @State private var selectedImage: UIImage?
    @State private var isPickerPresented = false
    @Environment(\.dismiss) var dismiss
    private var onItemTapped: ((CoffeeModel) -> Void)?
    
    let coffeeToEdit: CoffeeModel?
    
    init(coffee: CoffeeModel? = nil, onItemTapped: ((CoffeeModel) -> Void)?) {
        _title = State(initialValue: coffee?.title ?? "")
        _description = State(initialValue: coffee?.description ?? "")
        _isFavourite = State(initialValue: coffee?.favourite ?? false)
        self.coffeeToEdit = coffee
        self.onItemTapped = onItemTapped
    }
    
    var body: some View {
        VStack {
            if let selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150.0, alignment: .center)
            }
            Form {
                TextField(text: $title) {
                    Text("Coffee Name")
                }
                TextField(text: $description) {
                    Text("Description")
                }
                Toggle("Is it your favourite?", isOn: $isFavourite)
                
                Button("Choose photo") {
                   isPickerPresented = true
                }
            }
            .sheet(isPresented: $isPickerPresented) {
                ImagePicker(selectedImage: $selectedImage)
            }
            Button("Save") {
                let newItem = CoffeeModel(
                    title: title,
                    description: description,
                    ingredients: coffeeToEdit?.ingredients,
                    image: coffeeToEdit?.image,
                    favourite: isFavourite
                )
                onItemTapped?(newItem)
                dismiss()
            }
        }
    }
}

#Preview {
    let testCoffeeItem: CoffeeModel = .init(title: "Latte", description: "Description", ingredients: nil, image: nil, favourite: false)
    AddCoffeeView(coffee: testCoffeeItem, onItemTapped: {_ in })
}
