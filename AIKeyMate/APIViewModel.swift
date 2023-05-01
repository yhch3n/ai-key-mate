//
//  APIViewModel.swift
//  AIKeyMate
//
//  Created by yihandogs on 2023/4/29.
//

import Foundation
import Alamofire
import SwiftyJSON

struct PromptOption: Decodable {
    let key: String
    let value: String

    init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}

class APIViewModel {
    // Define the API key and URL for the OpenAI API
    private let apiKey = "put-your-actual-api-key"
    private let apiUrl = "https://api.openai.com/v1/completions"
    private let jsonURL = "https://yhch3n.github.io/GPT-Prompts/prompts.json"

    func sendCompletionsQuery(input: String, completion: @escaping (String) -> Void) {
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

    func sendChatQuery(content: String, completion: @escaping (String) -> Void) {
        let apiUrl = "https://api.openai.com/v1/chat/completions"

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]

        let message = ["role": "user", "content": content]
        let parameters: Parameters = [
            "model": "gpt-3.5-turbo",
            "messages": [message]
        ]

        AF.request(apiUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let generatedText = json["choices"][0]["message"]["content"].stringValue
                completion(generatedText)
            case .failure(let error):
                print(error.localizedDescription)
                completion("Error: \(error.localizedDescription)")
            }
        }
    }

    func loadPromptOptions(completion: @escaping ([PromptOption]) -> Void) {
        guard let url = URL(string: jsonURL) else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }

            if let data = data {
                do {
                    let jsonData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: String]
                    var promptOptions: [PromptOption] = []

                    jsonData?.forEach { key, value in
                        let promptOption = PromptOption(key: key, value: value)
                        promptOptions.append(promptOption)
                        print(promptOption.key)
                    }

                    DispatchQueue.main.async {
                        completion(promptOptions)
                    }
                } catch {
                    print("Error parsing JSON data: \(error)")
                }
            }
        }.resume()
    }
}
