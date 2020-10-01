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
    private let appName: String
    private let country: String
    private let rawURL: String
    
    init(appId: String, appName: String, country: String) {
        self.appId = appId
        self.appName = appName
        self.country = country
        let countryPath = country.count == 2 ? "\(country)/" : ""
        rawURL = String(format: reviewsURLFormat, countryPath, appId)
    }
    
    func reviews(completion: @escaping ([Review]) -> Void) {
        
        guard let url = URL(string: rawURL) else {
            completion([])
            return
        }
        
        let appName = self.appName
        let country = self.country
        
        let session = URLSession.shared
        session.dataTask(with: url) { [weak self] (data, response, error) in
            var reviews: [Review] = []
            
            guard let strongSelf = self,
                let data = data,
                let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any],
                let feed = json["feed"] as? [String: Any],
                let entries = feed["entry"] as? [[String: Any]] else {
                    completion(reviews)
                    return
            }
            
            for case let entry in entries {
                if let review = try? Review(json: entry, appId: strongSelf.appId, appName: appName, country: country) {
                    reviews.append(review)
                }
            }
            
            completion(reviews)
            
            }.resume()
    }
}
