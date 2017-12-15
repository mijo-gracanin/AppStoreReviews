//
//  SlackController.swift
//  AppStoreReviews
//
//  Created by Mijo Gracanin on 03/12/2017.
//  Copyright © 2017 Mijo Gracanin. All rights reserved.
//

import Foundation


class SlackController {
    
    private let slackURLFormat = "https://hooks.slack.com/services/%@"
    private let rawURL: String
    
    init(slackHook: String) {
        rawURL = String(format:slackURLFormat, slackHook)
    }
    
    func sendOnlyNewReviews(reviews: [Review], completion: @escaping () -> Void) {
        guard let first = reviews.first else {
            completion()
            return
        }
        
        let lastReviewId = UserDefaults.standard.string(forKey: first.appId)
        print("lastReviewId: \(String(describing: lastReviewId))")
        var newReviews: [Review] = []
        for review in reviews {
            if review.id == lastReviewId {
                break
            }
            
            newReviews.append(review)
        }
        
        print("Sending \(newReviews.count) reviews to Slack")
        
        guard let newFirst = newReviews.first else {
            completion()
            return
        }
        UserDefaults.standard.set(newFirst.id, forKey: newFirst.appId)
        
        send(reviews: newReviews.reversed(), completion: completion)
    }
    
    func send(reviews: [Review], completion: @escaping () -> Void) {
        
        let json = getMessageJson(reviews: reviews)
        
        guard let url = URL(string: rawURL),
            let jsonData = try? JSONSerialization.data(withJSONObject: json) else {
                return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                    print("Send Slack message error: \(error.localizedDescription)")
            }
            completion()
        }.resume()
    }
    
    func getMessageJson(reviews: [Review]) -> [String: String] {
        var texts: [String] = []
        
        reviews.forEach { review in
            var stars = ""
            for _ in 0..<review.rating {
                stars = "\(stars) :star:"
            }
            let text = "*\(review.title)* (\(review.version)) \(stars)\n\(review.text)"
            
            texts.append(text)
        }
        
        let joinedTexts = texts.joined(separator: "\n\n\n")
        return ["text": joinedTexts]
    }
}
