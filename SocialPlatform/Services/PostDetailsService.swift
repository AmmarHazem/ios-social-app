//
//  PostDetailsService.swift
//  SocialPlatform
//
//  Created by Ammar on 1/23/21.
//

import Foundation

struct PostDetailsService {
    
    func fetchPost(with url: URL, complitionHandler: @escaping (PostModel?) -> Void) {
        let request = URLRequest(url: url)
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("--- fetchPost error 1")
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    complitionHandler(nil)
                }
                return
            }
            
            guard let response = response as? HTTPURLResponse,
                  let data = data else {
                DispatchQueue.main.async {
                    complitionHandler(nil)
                }
                return
            }
            
            if response.statusCode >= 200 && response.statusCode < 300 {
                let jsonDecoder = JSONDecoder()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = K.dateTimeFormat
                jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
                let postModel = try? jsonDecoder.decode(PostModel.self, from: data)
                DispatchQueue.main.async {
                    complitionHandler(postModel)
                }
            }
            else {
                let jsonData = try? JSONSerialization.jsonObject(with: data, options: [])
                print("--- fetchPost error 2")
                print(jsonData ?? "")
                DispatchQueue.main.async {
                    complitionHandler(PostModel(url: URL(string: K.baseURL)!, title: "", slug: "", content: "", user: URL(string: K.baseURL)!, published: false, created: Date(), likes: [], comments: []))
                }
            }
        }
        task.resume()
    }
    
    func addComment(token: String, postURL: URL, content: String, complitionHandler: @escaping (CommentModel?) -> Void) {
        let requestURL = URL(string: "\(K.baseURL)posts/post-comment/")!
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        let requestData: [String: Any] = ["content": content, "post": postURL.absoluteString]
        guard let requestJson = try? JSONSerialization.data(withJSONObject: requestData, options: []) else {
            print("--- add comment json serialization error")
            DispatchQueue.main.async {
                complitionHandler(nil)
            }
            return
        }
        request.httpBody = requestJson
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                print("--- add comment API error")
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    complitionHandler(nil)
                }
                return
            }
            
            let response = response as! HTTPURLResponse
            let data = data!
            
            if response.statusCode >= 200 && response.statusCode < 300 {
                print("--- add comment success")
//                let responseData = try? JSONSerialization.jsonObject(with: data, options: [])
//                print(responseData ?? "")
                let jsonDecoder = JSONDecoder()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = K.dateTimeFormat
                jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
                let model = try? jsonDecoder.decode(CommentModel.self, from: data)
                DispatchQueue.main.async {
                    complitionHandler(model)
                }
            }
            else {
                print("--- add comment API error")
                print("--- status code \(response.statusCode)")
                let responseData = try? JSONSerialization.jsonObject(with: data, options: [])
                print(responseData ?? "")
                DispatchQueue.main.async {
                    complitionHandler(nil)
                }
                return
            }
        }
        task.resume()
    }
    
    
    func fetch(comment url: URL, token: String, completionHandler: @escaping (CommentModel?) -> Void) {
        let request = URLRequest(url: url)
//        request.setValue("Authorization", forHTTPHeaderField: "token \(token)")
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("--- fetchComment error \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completionHandler(nil)
                }
                return
            }
            
            if let data = data,
               let response = response as? HTTPURLResponse,
               response.statusCode >= 200 && response.statusCode < 300 {
                
                let jsonDecoder = JSONDecoder()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.AAAAAAZ"
                jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
                
//                let responseData = try! JSONSerialization.jsonObject(with: data, options: [])
//                print("--- response data \(responseData)")
                
                let commentModel = try? jsonDecoder.decode(CommentModel.self, from: data)
                DispatchQueue.main.async {
//                    print("--- fetch comment success \(commentModel?.content ?? "nil")")
                    completionHandler(commentModel)
                }
            }
            else if let response = response as? HTTPURLResponse,
                    let data = data {
                print("--- status code \(response.statusCode)")
                let responseData = try? JSONSerialization.jsonObject(with: data, options: [])
                print("--- response \(responseData ?? "json parse error")")
            }
        }
        task.resume()
    }
    
    func toggleLike(for post: URL, token: String, complitionHandler: @escaping (Bool) -> Void) {
        let url = URL(string: "\(K.baseURL)posts/like/")!
        let requestData = ["post": post.absoluteString]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestData, options: []) else {
            complitionHandler(false)
            return
        }
        request.httpBody = jsonData
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: request) { data, response, error in
            
            if error != nil {
                DispatchQueue.main.async {
                    complitionHandler(false)
                }
                return
            }
            
            if let response = response as? HTTPURLResponse,
               response.statusCode >= 200 && response.statusCode < 300 {
                
                let responseData = try? JSONSerialization.jsonObject(with: data!, options: [])
                if let jsonResponse = responseData as? [String: Any?] {
                    print("--- like response success \(jsonResponse)")
                }
                DispatchQueue.main.async {
                    complitionHandler(true)
                }
                
            }
            else if let response = response as? HTTPURLResponse,
                    let data = data {
                print("--- response error \(response.statusCode)")
                let responseData = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseData = responseData {
                    print("--- response data \(responseData)")
                }
                DispatchQueue.main.async {
                    complitionHandler(false)
                }
            }
            else {
                DispatchQueue.main.async {
                    complitionHandler(false)
                }
            }
        }
        dataTask.resume()
    }
    
}
