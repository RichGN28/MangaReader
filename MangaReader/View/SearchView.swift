//
//  SearchView.swift
//  MangaReader
//
//  Created by Ricardo Gómez on 08/10/26.
//

import SwiftUI

/// Pantalla de búsqueda: escribe un título y muestra resultados de MangaDex.
struct SearchView: View {
    @State private var viewModel = SearchViewModel()

    var body: some View {
        content
            .navigationTitle("Buscar")
            .searchable(text: $viewModel.query, prompt: "Título del manga")
            // Se dispara cada vez que cambia el texto; la espera de 0.4 s evita
            // llamar a la API por cada letra (debounce) y se cancela solo al seguir escribiendo.
            .task(id: viewModel.query) {
                try? await Task.sleep(for: .milliseconds(400))
                if !Task.isCancelled {
                    await viewModel.search()
                }
            }
    }

    /// Clean Code: vistas pequeñas — cada estado tiene su propio bloque.
    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            ContentUnavailableView(
                "Busca un manga",
                systemImage: "magnifyingglass",
                description: Text("Escribe el título para ver resultados.")
            )

        case .loading:
            ProgressView("Buscando...")

        case .loaded(let mangas):
            if mangas.isEmpty {
                ContentUnavailableView(
                    "Sin resultados",
                    systemImage: "questionmark.magnifyingglass",
                    description: Text("Prueba con otro título.")
                )
            } else {
                List(mangas) { manga in
                    NavigationLink(destination: MangaDetailView(manga: manga)) {
                        MangaRowView(manga: manga)
                    }
                }
            }

        case .error(let message):
            ErrorView(message: message) {
                Task { await viewModel.search() }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SearchView()
    }
}
