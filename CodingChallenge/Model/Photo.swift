//
//  Photo.swift
//  CodingChallenge
//
//  Created by José Jacobo Contreras Trejo on 29/01/22.
//

import Foundation
import UIKit

struct Photos: Codable {
    var page = Int()
    var pages = Int()
    var perpage = Int()
    var total = Int()
    var photo = [Photo]()
}

struct Photo: Codable {
    var id = String()
    var owner = String()
    var secret = String()
    var server = String()
    var farm = Int()
    var title = String()
    var isfriend = Int()
    var isfamily = Int()
}


