//
//  NetworkError.swift
//  MangaReader
//
//  Created by Ricardo Gómez on 06/10/26.
//

import Foundation

/// Errores de red con mensajes legibles para el usuario.
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noConnection
    case invalidResponse(statusCode: Int)
    case decodingError(Error)
    case serverError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "La URL proporcionada no es válida."
        case .noConnection:
            return "Sin conexión a internet. Inténtalo de nuevo."
        case .invalidResponse(let statusCode):
            return "Respuesta no válida del servidor (código \(statusCode))."
        case .decodingError(let error):
            return "No se pudieron procesar los datos: \(error.localizedDescription)"
        case .serverError(let error):
            return "Error de conexión: \(error.localizedDescription)"
        }
    }
}
