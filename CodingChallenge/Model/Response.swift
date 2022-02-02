//
//  Response.swift
//  CodingChallenge
//
//  Created by José Jacobo Contreras Trejo on 31/01/22.
//

import Foundation


struct Response: Codable {
    var photos = Photos()
    var stat = String()
}

struct APIResponse: Codable {
    let results: [Photo]
}
