//
//  MangaService.swift
//  MangaReader
//
//  Created by Ricardo Gómez on 06/10/26.
//

import Foundation

// en esto me ayudo gemini
protocol MangaServiceProtocol {
    func fetchMangas(ids: [String]?) async throws -> [Manga]
}

final class MangaService: MangaServiceProtocol {
    private let session: URLSession
    private let baseURL = "https://api.mangadex.org"
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchMangas(ids: [String]? = nil) async throws -> [Manga] {
        // 1. Construir URL usando URLComponents de forma segura
        guard var components = URLComponents(string: "\(baseURL)/manga") else {
            throw NetworkError.invalidURL
        }
        
        // Incluir la relación de cover_art para recibir el fileName en relationships
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "includes[]", value: "cover_art"),
            URLQueryItem(name: "limit", value: "20")
        ]
        
        // Si especificamos una lista fija de IDs favoritos, los agregamos como filtros
        if let ids = ids, !ids.isEmpty {
            for id in ids {
                queryItems.append(URLQueryItem(name: "ids[]", value: id))
            }
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        // 2. Ejecutar la llamada de red con async/await
        let data: Data
        let response: URLResponse
        
        do {
            (data, response) = try await session.data(from: url)
        } catch {
            throw NetworkError.serverError(error)
        }
        
        // 3. Validar código HTTP de respuesta
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse(statusCode: -1)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse(statusCode: httpResponse.statusCode)
        }
        
        // 4. Decodificar el JSON al DTO y mapear a entidades de dominio
        do {
            let decoder = JSONDecoder()
            let responseDTO = try decoder.decode(MangaListResponseDTO.self, from: data)
            
            // Transformar MangaDataDTO -> Manga
            return responseDTO.data.map { Manga(from: $0) }
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}
