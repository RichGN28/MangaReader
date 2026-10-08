//
//  MangaDetailView.swift
//  MangaReader
//
//  Created by Ricardo Gómez on 07/10/26.
//

import SwiftUI

/// Vista de detalle (nivel 2 de navegación): muestra un manga completo.
struct MangaDetailView: View {
    let manga: Manga

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Portada grande
                AsyncImage(url: manga.coverURL) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(maxWidth: .infinity, maxHeight: 320)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .accessibilityLabel("Portada de \(manga.title)")   // accesibilidad

                // Título y estado
                Text(manga.title)
                    .font(.title)
                    .bold()
                Text("Estado: \(manga.status.capitalized)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                // Descripción
                Text("Descripción")
                    .font(.headline)
                Text(manga.description)
                    .font(.body)

                // Enlace para leer en MangaDex
                if let url = URL(string: "https://mangadex.org/title/\(manga.id)") {
                    Link(destination: url) {
                        Text("Leer en MangaDex")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.top, 8)
                }
            }
            .padding()
        }
        .navigationTitle("Detalles")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        MangaDetailView(manga: Manga(
            id: "demo",
            title: "One Piece",
            description: "La aventura de Luffy para convertirse en el Rey de los Piratas.",
            coverURL: nil,
            status: "ongoing"
        ))
    }
}
