//
//  MangaService.swift
//  MangaReader
//
//  Created by Ricardo Gómez on 06/10/26.
//

import Foundation

/// Clean Code: Single Responsibility — esta clase SOLO habla con la API de MangaDex.
/// Documentación: https://api.mangadex.org/docs/
final class MangaService {
    private let baseURL = "https://api.mangadex.org"

    /// GET: mangas más seguidos (orden descendente), incluyendo su portada.
    /// Endpoint: https://api.mangadex.org/manga
    func fetchPopularMangas() async throws -> [Manga] {
        let dto: MangaListResponseDTO = try await get("/manga", queryItems: [
            URLQueryItem(name: "limit", value: "20"),
            URLQueryItem(name: "includes[]", value: "cover_art"),       // pide el nombre del archivo de portada
            URLQueryItem(name: "order[followedCount]", value: "desc"),  // más populares primero
            URLQueryItem(name: "contentRating[]", value: "safe")        // solo contenido apto
        ])
        return dto.data.map { Manga(from: $0) }
    }

    /// GET: busca mangas por título. Endpoint: https://api.mangadex.org/manga?title=...
    func searchMangas(query: String) async throws -> [Manga] {
        let dto: MangaListResponseDTO = try await get("/manga", queryItems: [
            URLQueryItem(name: "title", value: query),
            URLQueryItem(name: "limit", value: "20"),
            URLQueryItem(name: "includes[]", value: "cover_art"),
            URLQueryItem(name: "contentRating[]", value: "safe")
        ])
        return dto.data.map { Manga(from: $0) }
    }

    /// GET: capítulos legibles (en español o inglés) de un manga.
    /// Endpoint: https://api.mangadex.org/chapter?manga=...
    func fetchChapters(mangaID: String) async throws -> [Chapter] {
        let dto: ChapterListResponseDTO = try await get("/chapter", queryItems: [
            URLQueryItem(name: "manga", value: mangaID),
            URLQueryItem(name: "translatedLanguage[]", value: "es"),
            URLQueryItem(name: "translatedLanguage[]", value: "en"),
            URLQueryItem(name: "order[chapter]", value: "asc"),
            URLQueryItem(name: "limit", value: "100")
        ])

        // Solo capítulos con páginas reales en MangaDex (los externos van a MangaPlus, etc.)
        let legibles = dto.data
            .filter { ($0.attributes.pages ?? 0) > 1 && $0.attributes.externalUrl == nil }
            .map { Chapter(from: $0) }
            .sorted { (Double($0.number) ?? .infinity) < (Double($1.number) ?? .infinity) }

        // Quitar duplicados: mismo número e idioma subido por distintos grupos
        var vistos = Set<String>()
        return legibles.filter { vistos.insert("\($0.number)-\($0.language)").inserted }
    }

    /// GET: URLs de las páginas de un capítulo.
    /// Endpoint: https://api.mangadex.org/at-home/server/{chapterId}
    func fetchChapterPages(chapterID: String) async throws -> [URL] {
        let dto: AtHomeResponseDTO = try await get("/at-home/server/\(chapterID)")
        return dto.chapter.data.compactMap { fileName in
            URL(string: "\(dto.baseUrl)/data/\(dto.chapter.hash)/\(fileName)")
        }
    }

    /// Clean Code: DRY — una sola función hace la petición, valida y decodifica;
    /// los métodos de arriba solo definen la ruta y los parámetros.
    private func get<T: Decodable>(_ path: String, queryItems: [URLQueryItem] = []) async throws -> T {
        // 1. Construir la URL de forma segura con URLComponents
        guard var components = URLComponents(string: baseURL + path) else {
            throw NetworkError.invalidURL
        }
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        guard let url = components.url else { throw NetworkError.invalidURL }

        // 2. Ejecutar la petición con async/await
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(from: url)
        } catch let error as URLError where error.code == .notConnectedToInternet {
            throw NetworkError.noConnection   // caso amigable cuando no hay internet
        } catch {
            throw NetworkError.serverError(error)
        }

        // 3. Validar el código HTTP de la respuesta
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
        guard (200...299).contains(statusCode) else {
            throw NetworkError.invalidResponse(statusCode: statusCode)
        }

        // 4. Decodificar el JSON
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}
