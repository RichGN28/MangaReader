//
//  ChapterReaderView.swift
//  MangaReader
//
//  Created by Ricardo Gómez on 08/10/26.
//

import SwiftUI

/// Lector: muestra las páginas del capítulo en scroll vertical (estilo webtoon).
struct ChapterReaderView: View {
    let chapter: Chapter
    let viewModel: ReaderViewModel

    var body: some View {
        content
            .navigationTitle("Capítulo \(chapter.number)")
            .navigationBarTitleDisplayMode(.inline)
            .task { await viewModel.loadPages(chapterID: chapter.id) }
            .onDisappear { viewModel.pages = [] }   // liberar memoria al salir
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoadingPages {
            ProgressView("Cargando páginas...")
        } else if let error = viewModel.pagesError {
            ErrorView(message: error) {
                Task { await viewModel.loadPages(chapterID: chapter.id) }
            }
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.pages, id: \.self) { pageURL in
                        MangaPageView(url: pageURL)
                    }
                }
            }
        }
    }
}

/// Una página del manga: se descarga y muestra a lo ancho de la pantalla.
struct MangaPageView: View {
    let url: URL

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 200)
            case .success(let image):
                image.resizable().scaledToFit()
            case .failure:
                Text("No se pudo cargar esta página")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 200)
            @unknown default:
                EmptyView()
            }
        }
        .accessibilityLabel("Página del capítulo")   // accesibilidad
    }
}
