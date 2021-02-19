//
//  HomeService.swift
//  SocialPlatform
//
//  Created by Ammar on 1/15/21.
//

import Foundation

enum FetchTimelineError: Error {
    case responseError
    case decodeJsonError
}

struct HomeService {
    var delegate: HomeServiceDelegate?
    
    func createPost(token: String, title: String, content: String) {
        let url = URL(string: "\(K.baseURL)posts/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestData: [String: String] = ["title": title, "content": content]
        guard let requestJsonData = try? JSONSerialization.data(withJSONObject: requestData, options: []) else {
            print("--- create post error 1")
            self.delegate?.didCreateNew(post: nil)
            return
        }
        request.httpBody = requestJsonData
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                print("--- create post error 2")
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self.delegate?.didCreateNew(post: nil)
                }
                return
            }
            
            let response = response as! HTTPURLResponse
            let data = data!
            let responseData = try? JSONSerialization.jsonObject(with: data, options: [])
            print(responseData ?? "")
            print(response.statusCode)
            if response.statusCode >= 200 && response.statusCode < 300 {
                print("--- create post success")
                
                let jsonDecoder = JSONDecoder()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = K.dateTimeFormat
                jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
                let newPost = try? jsonDecoder.decode(PostModel.self, from: data)
                DispatchQueue.main.async {
                    self.delegate?.didCreateNew(post: newPost)
                }
            }
            else {
                print("--- create post error 3")
                DispatchQueue.main.async {
                    self.delegate?.didCreateNew(post: nil)
                }
                return
            }
        }
        task.resume()
    }
    
    func getHomeTimeline(token: String) {
        guard let url = URL(string: "\(K.baseURL)timeline/") else { return }
        let session = URLSession(configuration: .default)
        var request = URLRequest(url: url)
        request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        let dataTask = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("--- response error \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.delegate?.didFetchTimeline(model: nil, error: FetchTimelineError.responseError)
                }
                return
            }
            
            guard let data = data,
                  let response = response as? HTTPURLResponse,
                  response.statusCode >= 200 && response.statusCode < 300 else {
                DispatchQueue.main.async {
                    self.delegate?.didFetchTimeline(model: nil, error: FetchTimelineError.responseError)
                }
                return
            }
            let jsonDecoder = JSONDecoder()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = K.dateTimeFormat
            jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
            if let timelineModel = try? jsonDecoder.decode(TimelineModel.self, from: data) {
                DispatchQueue.main.async {
                    self.delegate?.didFetchTimeline(model: timelineModel, error: nil)
                }
            }
            else {
                print("--- json docode error ")
                DispatchQueue.main.async {
                    self.delegate?.didFetchTimeline(model: nil, error: FetchTimelineError.decodeJsonError)
                }
            }
        }
        dataTask.resume()
    }
    
    func groupIntoSectionsByDate(posts: [PostModel], sortDesc: Bool = true) -> [PostsSectionModel<Date>] {
        let calendar = Calendar.current
        let groupsDict = Dictionary(grouping: posts) { (post) -> Date in
            let postDayComponents = calendar.dateComponents([.year, .month, .day], from: post.created)
            return calendar.date(from: postDayComponents)!
        }
        return groupsDict.map { date, posts -> PostsSectionModel<Date> in
            PostsSectionModel(section: date, posts: posts)
        }.sorted { (section1, section2) -> Bool in
            if sortDesc {
                return section1.section > section2.section
            }
            return section1.section < section2.section
        }
    }
    
    func groupIntoSectionsAlphabetically(posts: [PostModel], sortDesc: Bool = true) -> [PostsSectionModel<String>] {
        let groupedPostsDict = Dictionary(grouping: posts) { (post) -> String in
            return post.title.first?.description ?? ""
        }
        return groupedPostsDict.map { char, posts -> PostsSectionModel<String> in
            PostsSectionModel(section: char, posts: posts)
        }.sorted { (section1, section2) -> Bool in
            if sortDesc {
                return section1.section > section2.section
            }
            return section1.section < section2.section
        }
    }
}

protocol HomeServiceDelegate {
    func didFetchTimeline(model: TimelineModel?, error: Error?)
    
    func didCreateNew(post: PostModel?)
}

extension HomeServiceDelegate {
    func didFetchTimeline(model: TimelineModel?, error: Error?) {
        
    }
    
    func didCreateNew(post: PostModel?) {
        
    }
}
