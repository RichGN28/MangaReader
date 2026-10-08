//
//  Manga.swift
//  MangaReader
//
//  Created by Ricardo Gómez on 06/10/26.

import Foundation

struct Manga: Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
    let coverURL: URL?
    let status: String
}

extension Manga {
    init(from dto: MangaDataDTO) {
        self.id = dto.id
        
        // titulo en ingles
        self.title = dto.attributes.title["en"] ?? dto.attributes.title.values.first ?? "Sin titulo"
        
        self.description = dto.attributes.description?["en"] ?? dto.attributes.description?.values.first ?? "Descripción no disponible"
        
        self.status = dto.attributes.status ?? "Desconocido"
        
        // Buscar el archivo del cover art
        let coverFileName = dto.relationships.first(where: { $0.type == "cover_art" })?
            .attributes?
            .fileName
     
        if let fileName = coverFileName {
                    self.coverURL = URL(string: "https://uploads.mangadex.org/covers/\(dto.id)/\(fileName).256.jpg")
                } else {
                    self.coverURL = nil
                }
        
    }
}
