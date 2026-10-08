//
//  ReaderViewModel.swift
//  MangaReader
//
//  Created by Ricardo Gómez on 08/10/26.
//

import Foundation

/// ViewModel del lector: carga la lista de capítulos y las páginas del capítulo elegido.
@Observable
@MainActor
final class ReaderViewModel {
    var chapters: [Chapter] = []
    var pages: [URL] = []
    var isLoadingChapters = false
    var isLoadingPages = false
    var chaptersError: String?
    var pagesError: String?

    private let service = MangaService()

    /// Carga los capítulos legibles del manga.
    func loadChapters(mangaID: String) async {
        isLoadingChapters = true
        chaptersError = nil
        do {
            chapters = try await service.fetchChapters(mangaID: mangaID)
        } catch {
            chaptersError = error.localizedDescription
        }
        isLoadingChapters = false
    }

    /// Carga las páginas de un capítulo (las URLs de las imágenes).
    func loadPages(chapterID: String) async {
        isLoadingPages = true
        pagesError = nil
        pages = []
        do {
            pages = try await service.fetchChapterPages(chapterID: chapterID)
        } catch {
            pagesError = error.localizedDescription
        }
        isLoadingPages = false
    }
}
