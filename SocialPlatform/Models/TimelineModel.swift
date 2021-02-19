//
//  TimelineModel.swift
//  SocialPlatform
//
//  Created by Ammar on 1/15/21.
//

import Foundation

struct TimelineModel: Decodable {
    let count: Int
    let next: URL?
    let previous: URL?
    let results: [PostModel]
}

struct PostsSectionModel<SectionType: Decodable>: Decodable {
    let section: SectionType
    let posts: [PostModel]
}

struct PostModel: Decodable {
    let url: URL
    let title: String
    let slug: String
    let content: String
    let user: URL
    let published: Bool
    let created: Date
    let likes: [String]
    var comments: [URL]
    
    mutating func addComment(url: URL) {
        self.comments.insert(url, at: 0)
    }
    
    var formattedCreatedDate: String {
        let callendar = Calendar.current
        let dateComponents = callendar.dateComponents([.year, .month, .day, .hour, .minute], from: self.created)
        return "\(dateComponents.day!)-\(dateComponents.month!)-\(dateComponents.year!) \(dateComponents.hour!):\(dateComponents.minute!)"
    }
}
