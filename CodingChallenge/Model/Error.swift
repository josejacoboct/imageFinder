//
//  Error.swift
//  CodingChallenge
//
//  Created by José Jacobo Contreras Trejo on 31/01/22.
//

import Foundation

enum NetworkManagerError: LocalizedError {
    
    case invalidURL
    case unsuccessResponse
    case badResponse
    case unsuccessData
    
    var description: String? {
        switch self {
        case .invalidURL:
            return "It's no posible create a valid URL with the image data or the input text."
        case .badResponse:
            return "The server respond with a bad code."
        case .unsuccessResponse:
            return "We can't connect with the server."
        case .unsuccessData:
            return "We can't convert the data."
        }
    }
}
