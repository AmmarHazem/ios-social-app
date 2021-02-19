//
//  ProfileService.swift
//  SocialPlatform
//
//  Created by Ammar on 2/4/21.
//

import Foundation

struct ProfileService {
    
    let session = URLSession(configuration: .default)
    
    func fetchProfile(with token: String, complitionHandler: @escaping (UserModel?) -> Void) {
        let url = URL(string: "\(K.baseURL)profile/")!
        var request = URLRequest(url: url)
        request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        let task = session.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("--- fetch profile error 1")
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    complitionHandler(nil)
                }
                return
            }
            
            let response = response as! HTTPURLResponse
            let data = data!
            if response.statusCode >= 200 && response.statusCode < 300 {
                let jsonDecoder = JSONDecoder()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = K.dateTimeFormat
                jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
                let userModel = try? jsonDecoder.decode(UserModel.self, from: data)
                DispatchQueue.main.async {
                    complitionHandler(userModel)
                }
            }
            else {
                print("--- fetch profile error 2")
                let responseData = try? JSONSerialization.jsonObject(with: data, options: [])
                print(responseData ?? "nil")
                DispatchQueue.main.async {
                    complitionHandler(nil)
                }
            }
        }
        task.resume()
    }
}
