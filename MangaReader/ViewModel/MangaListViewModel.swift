//
//  MangaListViewModel.swift
//  MangaReader
//
//  Created by Ricardo Gómez on 07/10/26.
//

import Foundation

/// Estados posibles de la pantalla de lista.
/// Clean Code: nombres descriptivos — la vista solo reacciona al estado.
enum MangaListViewState: Equatable {
    case idle
    case loading
    case loaded([Manga])
    case error(String)
}

/// ViewModel: conecta el servicio (Model) con la vista, sin lógica de UI.
/// @Observable + @MainActor: la vista se actualiza sola cuando cambia `state`.
@Observable
@MainActor
final class MangaListViewModel {
    var state: MangaListViewState = .idle

    private let service = MangaService()

    /// Carga la lista de mangas y traduce cualquier fallo a un estado de error
    /// (la app nunca truena por un error de red).
    func loadMangas() async {
        state = .loading
        do {
            state = .loaded(try await service.fetchPopularMangas())
        } catch let error as NetworkError {
            state = .error(error.localizedDescription)
        } catch {
            state = .error("Ocurrió un error inesperado. Inténtalo de nuevo.")
        }
    }
}
