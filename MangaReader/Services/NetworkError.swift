//
//  NetworkError.swift
//  MangaReader
//
//  Created by Ricardo Gómez on 06/10/26.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse(statusCode: Int)
    case decodingError(Error)
    case serverError(Error)
    
    var errorDescription: String? {
        switch self {
            
        case .invalidURL:
            return "La URL proporcionada no es válida"
            
        case .invalidResponse(let statusCode):
            return "Respuesta no válida del servidor (Código de estado: \(statusCode))."
            
        case .decodingError(let error):
            return "Fallo al procesar los datos recibidos: \(error.localizedDescription)"
            
        case .serverError(let error):
                    return "Error de conexión: \(error.localizedDescription)"
        }
    }
}
