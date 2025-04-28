//
//  APIClient.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/27/25.
//

import Foundation

final class APIClient {
    static let shared = APIClient()
    private init() {}
    
    private let baseURL = URL(string: "http://127.0.0.1:8080")!   //서버 이름
    private let session = URLSession.shared
    
    /// 제네릭 GET
    func get<T: Decodable>(_ endpoint: Endpoint,
                           as type: T.Type = T.self) async throws -> T {
        guard let url = URL(string: endpoint.path, relativeTo: baseURL) else {
            throw NetworkError.invalidURL
        }
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        
        let (data, resp) = try await session.data(for: req)
        
        // ② **여기서 Raw JSON 출력!**
                #if DEBUG
                if let json = String(data: data, encoding: .utf8) {
                    print("🔵 [\(endpoint.path)] Raw-Response ↓↓↓\n\(json)\n")
                }
                #endif
        
        guard let http = resp as? HTTPURLResponse else { throw NetworkError.unknown }
        guard 200..<300 ~= http.statusCode else {
            let body = String(decoding: data, as: UTF8.self)
            print("❌ HTTP \(http.statusCode)\n\(body)")
            throw NetworkError.status(http.statusCode)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .formatted(DateFormatter.yyyyMMdd)   // 기본
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decoding(error)
        }
    }
}
