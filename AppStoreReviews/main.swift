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
    print("AppStoreReviews -appId <appId> -appName <appName> -country <country> -slackHookId <slackHookId>")
    print("Only -appId <appId> parameter is required")
    print("Example: AppStoreReviews -appId 584557117 -appName Foo -country us -slackHookId H025Z4AC2/C79K73V5F/mqYPNbojxiSAVhZ1E7msDfQW")
}

let arguments = CommandLine.arguments
let flags = Set(["-appId", "-appName", "-country", "-slackHookId"])
var appId = ""
var appName = ""
var country = ""
var slackHookId = ""

if arguments.count == 1 && arguments.count % 2 == 0 {
    printHelp()
}
else {
    for index in 1..<(arguments.count) {
        if index % 2 == 0 {
            continue
        }
        
        let argument = arguments[index]
        if argument == "-appId" {
            appId = arguments[index + 1]
        } else if argument == "-appName" {
            appName = arguments[index + 1]
        } else if argument == "-country" {
            country = arguments[index + 1]
        } else if argument == "-slackHookId" {
            slackHookId = arguments[index + 1]
        } else {
            printHelp()
            exit(0)
        }
    }

    let semaphore = DispatchSemaphore(value: 0)

    let reviewsController = ReviewsController(appId: appId, appName: appName, country: country)
    let slackController = SlackController(slackHook: slackHookId)

    reviewsController.reviews() { reviews in
        if slackHookId.isEmpty {
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


