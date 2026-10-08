//
//  MangaDTO.swift
//  MangaReader
//
//  Created by Ricardo Gómez on 06/10/26.
//

import Foundation

struct MangaListResponseDTO: Decodable {
    let data: [MangaDataDTO]
}

struct MangaDataDTO: Decodable {
    let id: String
    let attributes: MangaAttributesDTO
    let relationships: [RelationshipDTO]
}

struct MangaAttributesDTO: Decodable {
    let title: [String: String]
    let description: [String: String]?
    let status: String?
}

struct RelationshipDTO: Decodable {
    let id: String
    let type: String
    let attributes: RelationshipAttributesDTO?
}

struct RelationshipAttributesDTO: Decodable {
    let fileName: String?
}
