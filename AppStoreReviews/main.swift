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
let allCountries = ["ae", "ag", "ai", "al", "am", "ao", "ar", "at", "au", "az", "bb", "be", "bf", "bg", "bh", "bj", "bm", "bn", "bo", "br", "bs", "bt", "bw", "by", "bz", "ca", "cg", "ch", "cl", "cn", "co", "cr", "cv", "cy", "cz", "de", "dk", "dm", "do", "dz", "ec", "ee", "eg", "es", "fi", "fj", "fm", "fr", "gb", "gd", "gh", "gm", "gr", "gt", "gw", "gy", "hk", "hn", "hr", "hu", "id", "ie", "il", "in", "is", "it", "jm", "jo", "jp", "ke", "kg", "kh", "kn", "kr", "kw", "ky", "kz", "la", "lb", "lc", "lk", "lr", "lt", "lu", "lv", "md", "mg", "mk", "ml", "mn", "mo", "mr", "ms", "mt", "mu", "mw", "mx", "my", "mz", "na", "ne", "ng", "ni", "nl", "np", "no", "nz", "om", "pa", "pe", "pg", "ph", "pk", "pl", "pt", "pw", "py", "qa", "ro", "ru", "sa", "sb", "sc", "se", "sg", "si", "sk", "sl", "sn", "sr", "st", "sv", "sz", "tc", "td", "th", "tj", "tm", "tn", "tr", "tt", "tw", "tz", "ua", "ug", "us", "uy", "uz", "vc", "ve", "vg", "vn", "ye", "za", "zw"]

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

    let slackController = SlackController(slackHook: slackHookId)
    
    let countries: [String]
    
    if (country.count == 2) {
        countries = [country]
    } else {
        countries = allCountries
    }

    for country in countries {
        ReviewsController.getReviews(appId: appId, appName: appName, country: country) { reviews in
            if slackHookId.isEmpty {
                print(reviews)
                semaphore.signal()
            } else {
                slackController.sendOnlyNewReviews(reviews: reviews) {
                    semaphore.signal()
                }
            }
        }
        semaphore.wait()
    }
}


