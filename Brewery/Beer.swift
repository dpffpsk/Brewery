//
//  Beer.swift
//  Brewery
//
//  Created by 이니텍 on 2022/01/05.
//

import Foundation
import UIKit

struct Beer: Decodable {
    let id: Int?
    let name, taglineString, description, imageURL, brewersTips: String?
    let foodPairing: [String]?
    
    var tagLine: String {
        let tags = taglineString?.components(separatedBy: ". ")
        debugPrint("1111111111111111111111")
        debugPrint(tags)
        let hashtags = tags?.map {
            "#" + $0.replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: ".", with: "")
                .replacingOccurrences(of: ",", with: " #")
        }
        debugPrint("222222222222222222222")
        debugPrint(hashtags)
        return hashtags?.joined(separator: " ") ?? "" //ex)#tag #hashtag
    }
    
    enum Codingkeys: String, CodingKey {
        case taglineString = "tagline"
        case imageURL = "image_url"
        case brewersTips = "brewers_tips"
        case foodPairing = "food_pairing"
        case id, name, description
    }
}
