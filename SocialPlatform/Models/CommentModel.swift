//
//  CommentModel.swift
//  SocialPlatform
//
//  Created by Ammar on 1/25/21.
//

import Foundation

struct CommentModel: Decodable {
    let url: URL
    let content: String
    let post: URL
    let user: URL
    let created: Date
    
    var username: String {
        var urlString = user.absoluteString
        guard !urlString.isEmpty else { return "" }
        let _ = urlString.popLast()
        var startIndex = urlString.lastIndex(of: "/")!
        startIndex = urlString.index(after: startIndex)
        let nameSubString = urlString.suffix(from: startIndex)
        return String(nameSubString)
    }
}
