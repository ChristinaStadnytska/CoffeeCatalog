//
//  CoffeeImageView.swift
//  CoffeeCatalog
//
//  Created by Christina Stadnytska on 22.07.2026.
//

import SwiftUI

struct CoffeeImageView: View {
    let imageURLString: String?
    
    var body: some View {
        if let imageURLString, let url = URL(string: imageURLString) {
            
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image): image.resizable().scaledToFit()
                case .failure: Image(systemName: "cup.and.saucer")
                case .empty: ProgressView()
                @unknown default: EmptyView()
                }
            }
        } else {
            Image(systemName: "cup.and.saucer")
        }
    }
}
