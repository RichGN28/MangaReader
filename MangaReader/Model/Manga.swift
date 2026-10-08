//
//  Manga.swift
//  MangaReader
//
//  Created by Ricardo Gómez on 06/10/26.
//

import Foundation

/// Modelo de la app: solo los campos que la UI necesita.
struct Manga: Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
    let coverURL: URL?
    let status: String
}

extension Manga {
    /// Dato de ejemplo para los #Preview de Xcode (no se usa en producción).
    static let sample = Manga(
        id: "sample",
        title: "Sousou no Frieren",
        description: "La elfa Frieren emprende un nuevo viaje tras la muerte del héroe Himmel.",
        coverURL: nil,
        status: "ongoing"
    )

    /// Convierte el DTO de la API al modelo de la app.
    init(from dto: MangaDataDTO) {
        self.id = dto.id

        // Título en inglés; si no existe, el primero disponible
        self.title = dto.attributes.title["en"]
            ?? dto.attributes.title.values.first
            ?? "Sin título"

        self.description = dto.attributes.description?["en"]
            ?? dto.attributes.description?.values.first
            ?? "Descripción no disponible"

        self.status = dto.attributes.status ?? "Desconocido"

        // La portada llega como relación "cover_art"; se arma la URL con el fileName
        let fileName = dto.relationships
            .first(where: { $0.type == "cover_art" })?
            .attributes?.fileName

        if let fileName {
            self.coverURL = URL(string: "https://uploads.mangadex.org/covers/\(dto.id)/\(fileName).256.jpg")
        } else {
            self.coverURL = nil
        }
    }
}
