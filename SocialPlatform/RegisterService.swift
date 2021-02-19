//
//  RegisterService.swift
//  SocialPlatform
//
//  Created by Ammar on 1/11/21.
//

import Foundation


enum RegisterError: Error {
    case parseToJsonError
    case urlError
    case responseError
    case parseFromJsonError
}


struct RegisterService {
    func submitForm(data: [String: Any], completionHandler: @escaping (AuthModel?, Error?) -> Void) {
        guard let url = URL(string: "\(K.baseURL)register/") else {
            print("--- create URL error")
            DispatchQueue.main.async {
                completionHandler(nil, RegisterError.urlError)
            }
            return
        }
        let session = URLSession(configuration: .default)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: []) else {
            print("--- json encoding error")
            DispatchQueue.main.async {
                completionHandler(nil, RegisterError.parseToJsonError)
            }
            return
        }
        request.httpBody = jsonData
        let dataTask = session.dataTask(with: request) { data, response, error in
            print("--- dataTask completed")
            if let error = error {
                print("--- register error")
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    completionHandler(nil, RegisterError.responseError)
                }
                return
            }
            print((response as? HTTPURLResponse)?.statusCode ?? "")
            guard let data = data else { return }
            do {
                let jsonDecoder = JSONDecoder()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = K.dateTimeFormat
                jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
                let authModel = try jsonDecoder.decode(AuthModel.self, from: data)
                DispatchQueue.main.async {
                    completionHandler(authModel, nil)
                }
            }
            catch {
                print("--- parse auth model error")
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    completionHandler(nil, RegisterError.parseFromJsonError)
                }
            }
//            if let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//                print(jsonData)
//
//            }
        }
        dataTask.resume()
    }
    
    func validatePasswordConfirmation(passwordConfermation: String?, password: String?) -> String {
        if passwordConfermation?.isEmpty ?? true {
            return " - Please confirm your password"
        }
        else if passwordConfermation != password {
            return " - Password fields didn't match"
        }
        return ""
    }
}
