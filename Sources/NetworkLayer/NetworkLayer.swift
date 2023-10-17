//
//  checkingPackage.swift
//  requestapp
//
//  Created by Sreepriya M on 17/10/23.
//

import Foundation
public class NetworkManager {

    // MARK: - Shared instance
    public static let shared = NetworkManager()

    public init() {}

    // MARK: - Public methods

    public func request<T: Decodable>(
        method: HTTPMethod,
        url: URL,
        body: Data? = nil,
        responseType: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("Application/json", forHTTPHeaderField: "content-Type")
        request.httpBody = body


        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

             //Handle DELETE response without decoding
            if T.self == EmptyResponse.self {
                completion(.success(EmptyResponse() as! T))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
                return
            }

            do {
                //let decodedData = try JSONDecoder().decode(responseType, from: data)
                let decodedData = try JSONDecoder().decode(responseType, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(error))
            }
        }
        .resume()
    }
}

// MARK: - HTTPMethod Enum
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
}

// MARK: - EmptyResponse Struct
public struct EmptyResponse: Codable {
    // This struct represents an empty response for DELETE requests
}


