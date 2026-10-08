//
//  MangaListView.swift
//  MangaReader
//
//  Created by Ricardo Gómez on 07/10/26.
//

import SwiftUI

/// Vista de lista (nivel 1 de navegación). Solo dibuja según el estado del ViewModel.
struct MangaListView: View {
    @State private var viewModel: MangaListViewModel

    /// Permite inyectar un ViewModel (útil para previews); por defecto usa uno nuevo.
    @MainActor
    init(viewModel: MangaListViewModel? = nil) {
        _viewModel = State(initialValue: viewModel ?? MangaListViewModel())
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Mangas Populares")
                // Solo carga si no hay datos aún (evita recargar al volver del detalle)
                .task {
                    if case .idle = viewModel.state {
                        await viewModel.loadMangas()
                    }
                }
        }
    }

    /// Clean Code: vistas pequeñas — el switch vive aparte para que `body` quede legible.
    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView("Cargando mangas...")   // estado de carga

        case .loaded(let mangas):
            List(mangas) { manga in
                NavigationLink(destination: MangaDetailView(manga: manga)) {
                    MangaRowView(manga: manga)
                }
            }

        case .error(let message):
            ErrorView(message: message) {        // error + botón de reintento
                Task { await viewModel.loadMangas() }
            }
        }
    }
}

/// Fila de la lista: portada, título y estado del manga.
struct MangaRowView: View {
    let manga: Manga

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: manga.coverURL) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 50, height: 75)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .accessibilityHidden(true)   // la portada es decorativa en la lista

            VStack(alignment: .leading, spacing: 4) {
                Text(manga.title)
                    .font(.headline)
                    .lineLimit(2)
                Text(manga.status.capitalized)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)   // accesibilidad: una sola entrada por manga
    }
}

/// Mensaje de error amigable con opción de reintentar.
struct ErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.exclamationmark")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button("Reintentar", action: onRetry)
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    // Preview con datos de ejemplo: se ve al instante, sin esperar a la red
    MangaListView(viewModel: .preview)
}
