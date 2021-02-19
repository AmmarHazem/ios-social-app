//
//  LoginService.swift
//  SocialPlatform
//
//  Created by Ammar on 1/11/21.
//

import Foundation

enum LoginError: Error {
    case URLError
    case ParseJson
    case ResponseError
}

struct LoginService {
    func login(username: String, password: String, complitionHandler: @escaping (Error?, AuthModel?) -> Void) {
        guard let url = URL(string: "\(K.baseURL)login/") else {
            DispatchQueue.main.async {
                complitionHandler(LoginError.URLError, nil)
            }
            return
        }
        let jsonDict: [String: Any] = ["username": username, "password": password]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonDict, options: []) else {
            DispatchQueue.main.async {
                complitionHandler(LoginError.ParseJson, nil)
            }
            return
        }
        let session = URLSession(configuration: .default)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        let dataTask = session.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    complitionHandler(error, nil)
                }
                return
            }
            
            if response as? HTTPURLResponse != nil {
                let jsonDecoder = JSONDecoder()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = K.dateTimeFormat
                jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
                let authModel = try? jsonDecoder.decode(AuthModel.self, from: data!)
                DispatchQueue.main.async {
                    complitionHandler(nil, authModel)
                }
            }
        }
        dataTask.resume()
    }
}
