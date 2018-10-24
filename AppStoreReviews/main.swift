//
//  main.swift
//  AppStoreReviews
//
//  Created by Mijo Gracanin on 02/12/2017.
//  Copyright © 2017 Mijo Gracanin. All rights reserved.
//

import Foundation


print("AppStoreReview started \(Date())")

fileprivate func printHelp() {
    print("Usage:")
    print("AppStoreReviews -a <appId> -c <store_country> -s <slack_hook_id>")
    print("Only -a <appId> parameter is required")
    print("Example: AppStoreReviews -a 584557117 -c us -s H025Z4HF2/C79K73V5F/mqYPNbojxiSAVhZ1E7msDfQW")
}

let arguments = CommandLine.arguments
let flags = Set(["-a", "-c", "-s"])
var appId = ""
var country = ""
var slackHook = ""

if arguments.count == 1 && arguments.count % 2 == 0 {
    printHelp()
}
else {
    for index in 1..<(arguments.count - 1) {
        let argument = arguments[index]
        if argument == "-a" {
            appId = arguments[index + 1]
        } else if argument == "-c" {
            country = arguments[index + 1]
        } else if argument == "-s" {
            slackHook = arguments[index + 1]
        }
    }

    let semaphore = DispatchSemaphore(value: 0)

    let reviewsController = ReviewsController(appId: appId, country: country)
    let slackController = SlackController(slackHook: slackHook)

    reviewsController.reviews() { reviews in
        if slackHook.isEmpty {
            print(reviews)
        } else {
            slackController.sendOnlyNewReviews(reviews: reviews) {
                print("")
                semaphore.signal()
            }
        }
    }

    semaphore.wait()
}


