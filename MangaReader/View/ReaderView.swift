//
//  ReaderView.swift
//  MangaReader
//
//  Created by Ricardo Gómez on 08/10/26.
//

import SwiftUI

/// Lista de capítulos legibles de un manga (pantalla previa a la lectura).
struct ReaderView: View {
    let manga: Manga
    @State private var viewModel = ReaderViewModel()

    var body: some View {
        content
            .navigationTitle(manga.title)
            .navigationBarTitleDisplayMode(.inline)
            .task { await viewModel.loadChapters(mangaID: manga.id) }
    }

    /// Clean Code: vistas pequeñas — cada estado tiene su propio bloque.
    @ViewBuilder
    private var content: some View {
        if viewModel.isLoadingChapters {
            ProgressView("Cargando capítulos...")
        } else if let error = viewModel.chaptersError {
            ErrorView(message: error) {
                Task { await viewModel.loadChapters(mangaID: manga.id) }
            }
        } else if viewModel.chapters.isEmpty {
            // Algunos mangas solo se pueden leer fuera de MangaDex (licencia oficial)
            VStack(spacing: 12) {
                Image(systemName: "book.closed")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                Text("Este manga no tiene capítulos disponibles aquí.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            .padding()
        } else {
            List(viewModel.chapters) { chapter in
                NavigationLink(destination: ChapterReaderView(chapter: chapter, viewModel: viewModel)) {
                    ChapterRowView(chapter: chapter)
                }
            }
        }
    }
}

/// Fila de capítulo: número, título opcional e idioma.
struct ChapterRowView: View {
    let chapter: Chapter

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Capítulo \(chapter.number)")
                    .font(.headline)
                if !chapter.title.isEmpty {
                    Text(chapter.title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()
            Text(chapter.language.uppercased())   // ES / EN
                .font(.caption2)
                .bold()
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.15))
                .clipShape(Capsule())
        }
        .accessibilityElement(children: .combine)   // accesibilidad
    }
}
