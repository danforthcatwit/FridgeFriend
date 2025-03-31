//
//  FatSecretService.swift
//  FridgeFriend
//
//  Created by Colin James on 3/29/25.
//

// File for FatSecret API  URL Sessions

import Foundation
import Combine
import CryptoKit

class FatSecretService {
    private let apiKey: String
    private let apiSecret: String
    private let baseURL: String
    private let oauthURL: String
    private var accessToken: String?
    
    init(apiKey: String, apiSecret: String, baseURL: String, oauthURL: String) {
        self.apiKey = apiKey
        self.apiSecret = apiSecret
        self.baseURL = baseURL
        self.oauthURL = oauthURL
    }
    
    private func getAccessToken() -> AnyPublisher<String, Error> {
        // Create token request parameters
        let parameters = [
            "grant_type": "client_credentials",
            "client_id": apiKey,
            "client_secret": apiSecret
        ]
        
        // Create URL request
        guard let url = URL(string: oauthURL) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = parameters
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)
        
        // Perform token request
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .tryMap { data -> String in
                struct TokenResponse: Codable {
                    let access_token: String
                }
                
                let decoder = JSONDecoder()
                let response = try decoder.decode(TokenResponse.self, from: data)
                return response.access_token
            }
            .eraseToAnyPublisher()
    }
    
    func searchFoods(query: String) -> AnyPublisher<[String], Error> {
        // If we don't have a token, get one first
        if accessToken == nil {
            return getAccessToken()
                .flatMap { [weak self] token -> AnyPublisher<[String], Error> in
                    self?.accessToken = token
                    return self?.performSearch(query: query) ?? Fail(error: URLError(.badURL)).eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
        }
        
        return performSearch(query: query)
    }
    
    private func performSearch(query: String) -> AnyPublisher<[String], Error> {
        // Create endpoint URL
        let endpoint = "\(baseURL)/food/autocomplete/v2"
        
        // Create request parameters
        var parameters: [String: String] = [
            "expression": query,
            "format": "xml",
            "max_results": "10"
        ]
        
        // Build URL with query parameters
        var components = URLComponents(string: endpoint)
        components?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        guard let url = components?.url else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        print("Request URL: \(url)") // Debug log
        
        // Create request with authorization header
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken ?? "")", forHTTPHeaderField: "Authorization")
        
        // Perform network request
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .tryMap { [weak self] data -> [String] in
                // Check for token error
                if let error = try? JSONDecoder().decode(TokenError.self, from: data) {
                    // If token is invalid, clear it and retry
                    self?.accessToken = nil
                    return []
                }
                return self?.parseXMLResponse(data: data) ?? []
            }
            .eraseToAnyPublisher()
    }
    
    private func parseXMLResponse(data: Data) -> [String] {
        print("Raw XML response: \(String(data: data, encoding: .utf8) ?? "Unable to decode XML")") // Debug log
        var foodNames: [String] = []
        let parser = XMLParser(data: data)
        let delegate = XMLParserDelegate()
        parser.delegate = delegate
        parser.parse()
        
        return delegate.foodNames
    }
}

// Error response structure
private struct TokenError: Codable {
    let error: String
    let error_description: String
}
