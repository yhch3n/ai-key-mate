//
//  APIViewModel.swift
//  AIKeyMate
//
//  Created by yihandogs on 2023/4/29.
//

import Foundation
import Alamofire


class APIViewModel {
    // Define the API key and URL for the OpenAI API
    private let apiKey = "put-your-actual-api-key"
    private let apiUrl = "https://api.openai.com/v1/completions"

    func sendQuery(input: String, completion: @escaping (String) -> Void) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]

        let parameters: [String: Any] = [
            "model": "text-davinci-003",
            "prompt": input,
            "max_tokens": 7,
            "temperature": 0
        ]

        AF.request(apiUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let jsonResponse = value as? [String: Any],
                   let choices = jsonResponse["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let text = firstChoice["text"] as? String {
                    completion(text)
                } else {
                    completion("Error parsing the response.")
                }
            case .failure(let error):
                completion("Request failed: \(error.localizedDescription)")
            }
        }
    }
}
