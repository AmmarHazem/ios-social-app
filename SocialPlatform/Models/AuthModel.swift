//
//  UserModel.swift
//  SocialPlatform
//
//  Created by Ammar on 1/9/21.
//

import Foundation

struct AuthModel: Decodable {
    let token: String
    let user: UserModel
    
    init(fromDict dict: [String: Any]) {
        self.token = dict[K.tokenKey] as! String
        self.user = UserModel(fromDict: dict[K.userKey] as! [String: Any])
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "token": self.token,
            "user": self.user.toDictionary()
        ]
    }
}

struct UserModel: Decodable {
    let user: URL?
    let name: String
    let username: String
    let image: String?
    let bio: String
    let following: [URL?]
    let followers: [URL?]
    let posts: [URL?]?
    let created: Date
    
    init(fromDict dict: [String: Any]) {
        let urlStr = dict[K.userKey] as? String ?? ""
        self.user = URL(string: urlStr)
        self.name = dict[K.nameKey] as! String
        self.username = dict[K.usernameKey] as! String
        self.image = dict[K.imageKey] as? String
        self.bio = dict[K.bioKey] as! String
        self.following = (dict[K.followingKey] as! [String]).map() { URL(string: $0) }
        self.followers = (dict[K.followersKey] as! [String]).map() { URL(string: $0) }
        self.posts = (dict[K.userPostsKey] as? [String])?.map() { URL(string: $0) }
        self.created = dict[K.createdKey] as! Date
    }
    
    func toDictionary() -> [String: Any?] {
        return [
            K.userKey: self.user?.absoluteString ?? "",
            K.nameKey: self.name,
            K.usernameKey: self.username,
            K.imageKey: self.image ?? "",
            K.bioKey: self.bio,
            K.followingKey: self.following.map() { $0?.absoluteString },
            K.followersKey: self.followers.map() { $0?.absoluteString },
            K.userPostsKey: self.posts?.map() { $0?.absoluteString } ?? [],
            K.createdKey: self.created,
        ]
    }
}
