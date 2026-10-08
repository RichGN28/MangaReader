//
//  Chapter.swift
//  MangaReader
//
//  Created by Ricardo Gómez on 08/10/26.
//

import Foundation

/// Modelo de la app: un capítulo legible de un manga.
struct Chapter: Identifiable, Hashable {
    let id: String
    let number: String    // "1", "2.5", etc.
    let title: String
    let language: String  // "es" o "en"
    let pages: Int
}

extension Chapter {
    /// Convierte el DTO de la API al modelo de la app.
    init(from dto: ChapterDataDTO) {
        self.id = dto.id
        self.number = dto.attributes.chapter ?? "?"
        self.title = dto.attributes.title ?? ""
        self.language = dto.attributes.translatedLanguage ?? "en"
        self.pages = dto.attributes.pages ?? 0
    }
}

// MARK: - DTOs (decodificación del JSON de MangaDex)

struct ChapterListResponseDTO: Decodable {
    let data: [ChapterDataDTO]
}

struct ChapterDataDTO: Decodable {
    let id: String
    let attributes: ChapterAttributesDTO
}

struct ChapterAttributesDTO: Decodable {
    let chapter: String?
    let title: String?
    let translatedLanguage: String?
    let pages: Int?
    let externalUrl: String?   // si existe, el capítulo vive fuera de MangaDex (no legible)
}

/// Respuesta de /at-home/server: servidor + hash + nombres de archivo de cada página.
struct AtHomeResponseDTO: Decodable {
    let baseUrl: String
    let chapter: AtHomeChapterDTO
}

struct AtHomeChapterDTO: Decodable {
    let hash: String
    let data: [String]   // nombres de archivo de las páginas
}
