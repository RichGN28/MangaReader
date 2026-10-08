//
//  SearchViewModel.swift
//  MangaReader
//
//  Created by Ricardo Gómez on 08/10/26.
//

import Foundation

/// ViewModel de la búsqueda: busca mangas por título.
/// Reutiliza MangaListViewState porque los estados son los mismos.
@Observable
@MainActor
final class SearchViewModel {
    var query = ""
    var state: MangaListViewState = .idle

    private let service = MangaService()

    func search() async {
        let texto = query.trimmingCharacters(in: .whitespaces)
        guard !texto.isEmpty else {
            state = .idle   // búsqueda vacía → volver al estado inicial
            return
        }
        state = .loading
        do {
            state = .loaded(try await service.searchMangas(query: texto))
        } catch let error as NetworkError {
            state = .error(error.localizedDescription)
        } catch {
            state = .error("Ocurrió un error inesperado. Inténtalo de nuevo.")
        }
    }
}
