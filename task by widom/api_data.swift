//
//  api_data.swift
//  task by wisdom
//
//  Created by Mani on 23/06/24.
//

import Foundation
import UIKit

struct photodata: Codable {
    var id: String?
    var author: String?
    var width: Int?
    var height: Int?
    var url: String?
    var download_url: String?
    var downloadedimage: Data?
    
    
}

struct downloadedphotos {
    var id: String?
    var author: String?
    var width: Int?
    var height: Int?
    var imagetoshow: UIImage?
    var ifcheckboxclicked: Bool = false
    
    var customDescription: String {
        guard let author = author else {
            return "Default description."
        }
        
        switch author {
        case "Alejandro Escamilla":
            return "Alejandro Escamilla is a photographer and designer known for his creative works and contributions to the art community."
        case "Paul Jarvis":
            return "Paul Jarvis is a designer, author, and entrepreneur known for his minimalist approach and thoughtful insights on creativity and business."
        default:
            return "Good and Well Talented Photographer."
        }
    }
}
