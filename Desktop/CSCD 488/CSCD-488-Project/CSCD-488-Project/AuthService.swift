//
//  AuthService.swift
//  CSCD-488-Project
//
//  Created by Jacob Lucas on 2/6/25.
//

import Foundation

class AuthService {
    
    private init() {}
    
    static let shared = AuthService()
    
    let serverURL: String = "https://glitch.com/edit/#!/cscd-488-project"
    let testMethod: String = "/api/hello"
    
    func testServerConnection() {
        guard let url = URL(string: serverURL + testMethod) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let body: [String: String] = ["key": "value"]
        guard let bodyData = try? JSONSerialization.data(withJSONObject: body) else {
            print("Error encoding body")
            return
        }
        
        request.httpBody = bodyData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            if let data = data {
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response: \(responseString)")
                }
            }
        }
        task.resume()
    }
}
