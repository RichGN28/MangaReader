//
//  MangaService.swift
//  MangaReader
//
//  Created by Ricardo Gómez on 06/10/26.
//

import Foundation

/// Clean Code: Single Responsibility — esta clase SOLO habla con la API de MangaDex.
final class MangaService {
    private let baseURL = "https://api.mangadex.org"

    /// GET: mangas más seguidos (orden descendente), incluyendo su portada.
    /// Endpoint usado: https://api.mangadex.org/manga
    func fetchPopularMangas() async throws -> [Manga] {
        // 1. Construir la URL de forma segura con URLComponents
        guard var components = URLComponents(string: "\(baseURL)/manga") else {
            throw NetworkError.invalidURL
        }
        components.queryItems = [
            URLQueryItem(name: "limit", value: "20"),
            URLQueryItem(name: "includes[]", value: "cover_art"),       // pide el nombre del archivo de portada
            URLQueryItem(name: "order[followedCount]", value: "desc"),  // más populares primero
            URLQueryItem(name: "contentRating[]", value: "safe")        // solo contenido apto
        ]
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

        // 4. Decodificar el JSON (DTO) y mapearlo al modelo de la app
        do {
            let dto = try JSONDecoder().decode(MangaListResponseDTO.self, from: data)
            return dto.data.map { Manga(from: $0) }
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}
