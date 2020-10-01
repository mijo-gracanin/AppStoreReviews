//
//  Review.swift
//  AppStoreReviews
//
//  Created by Mijo Gracanin on 02/12/2017.
//  Copyright © 2017 Mijo Gracanin. All rights reserved.
//

import Foundation

enum SerializationError: Error {
    case missing(String)
    case invalid(String, Any)
}


struct Review {
    let appId: String
    let appName: String
    let country: String
    let id: String
    let version: String
    let rating: Int
    let title: String
    let text: String
}


extension Review {
    init(json: [String: Any], appId: String, appName: String, country: String) throws {
        
        guard let idDict = json["id"] as? [String: Any],
            let id = idDict["label"] as? String else {
                throw SerializationError.missing("id")
        }
        
        guard let titleDict = json["title"] as? [String: Any],
            let title = titleDict["label"] as? String else {
                throw SerializationError.missing("title")
        }
        
        guard let textDict = json["content"] as? [String: Any],
            let text = textDict["label"] as? String else {
                throw SerializationError.missing("text")
        }
        
        guard let ratingDict = json["im:rating"] as? [String: Any],
            let ratingString = ratingDict["label"] as? String,
            let rating = Int(ratingString) else {
                throw SerializationError.missing("rating")
        }
        
        guard let versionDict = json["im:version"] as? [String: Any],
            let version = versionDict["label"] as? String else {
                throw SerializationError.missing("version")
        }
        
        self.appId = appId
        self.appName = appName
        self.country = country
        self.id = id
        self.title = title
        self.text = text
        self.rating = rating
        self.version = version
    }
    
    var defaultsKey: String {
        return "\(appName)_\(appId)_\(country)"
    }
}
