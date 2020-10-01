//
//  ReviewsController.swift
//  AppStoreReviews
//
//  Created by Mijo Gracanin on 02/12/2017.
//  Copyright © 2017 Mijo Gracanin. All rights reserved.
//

import Foundation


class ReviewsController {
    
    class func getReviews(appId: String, appName: String, country: String, completion: @escaping ([Review]) -> Void) {
        
        let reviewsURLFormat = "https://itunes.apple.com/%@rss/customerreviews/id=%@/sortBy=mostRecent/json"
        let countryPath = country.count == 2 ? "\(country)/" : ""
        let rawURL = String(format: reviewsURLFormat, countryPath, appId)
        
        guard let url = URL(string: rawURL) else {
            completion([])
            return
        }
        
        let session = URLSession.shared
        session.dataTask(with: url) { data, response, error in
            var reviews: [Review] = []
            
            guard let data = data,
                let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any],
                let feed = json["feed"] as? [String: Any],
                let entries = feed["entry"] as? [[String: Any]] else {
                    completion(reviews)
                    return
            }
            
            for case let entry in entries {
                if let review = try? Review(json: entry, appId: appId, appName: appName, country: country) {
                    reviews.append(review)
                }
            }
            
            completion(reviews)
            
            }.resume()
    }
}
