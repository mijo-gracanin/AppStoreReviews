//
//  ReviewsController.swift
//  AppStoreReviews
//
//  Created by Mijo Gracanin on 02/12/2017.
//  Copyright © 2017 Mijo Gracanin. All rights reserved.
//

import Foundation


class ReviewsController {
    
    private let reviewsURLFormat = "https://itunes.apple.com/%@rss/customerreviews/id=%@/sortBy=mostRecent/json"
    private let appId: String
    private let rawURL: String
    
    init(appId: String, country: String) {
        self.appId = appId
        let countryPath = country.count == 2 ? "\(country)/" : ""
        rawURL = String(format: reviewsURLFormat, countryPath, appId)
    }
    
    func reviews(completion: @escaping ([Review]) -> Void) {
        
        guard let url = URL(string: rawURL) else {
            completion([])
            return
        }
        
        let session = URLSession.shared
        session.dataTask(with: url) { [weak self] (data, response, error) in
            var reviews: [Review] = []
            
            guard let strongSelf = self,
                let data = data,
                let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any],
                let feed = json["feed"] as? [String: Any],
                let entries = feed["entry"] as? [[String: Any]],
                let first = entries.first,
                let nameDict = first["im:name"] as? [String: Any],
                let name = nameDict["label"] as? String else {
                    completion(reviews)
                    return
            }
            
            for case let entry in entries.reversed() {
                if let review = try? Review(json: entry, appId: strongSelf.appId, appName: name) {
                    reviews.append(review)
                }
            }
            
            completion(reviews)
            
            }.resume()
    }
}
