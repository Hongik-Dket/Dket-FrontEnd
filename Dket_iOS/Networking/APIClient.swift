//
//  APIClient.swift
//  Dket_iOS
//
//  Created by 이지우 o
//  4/27/25.
//

import Foundation

final class APIClient {
    static let shared = APIClient()
    private init() {}
    
    private static let baseURL = URL(string: "https://dket.kr")!
    private let session = URLSession.shared
    
    // MARK: - JSON Decoder 설정
    private static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        d.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let str = try container.decode(String.self)
            if let date = DateFormatter.yyyyMMdd.date(from: str) { return date }
            if let date = DateFormatter.yyyyMMddHHmmss.date(from: str) { return date }
            if let date = DateFormatter.yyyyMMddTHHmmss.date(from: str) { return date }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "지원하지 않는 날짜 형식: \(str)")
        }
        return d
    }()
    
}

// MARK: - GET 요청
extension APIClient {
    func get<T: Decodable>(_ endpoint: Endpoint, as type: T.Type = T.self) async throws -> T {
        var components = URLComponents()
        components.scheme = Self.baseURL.scheme
        components.host = Self.baseURL.host
        components.port = Self.baseURL.port
        components.path = endpoint.path
        components.queryItems = endpoint.queryItems
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        authorizedRequest(&request, for: endpoint)
        
        let (data, response) = try await session.data(for: request)
        
#if DEBUG
        if let raw = String(data: data, encoding: .utf8) {
            print("🔵 [GET \(endpoint.path)] Raw-Response ↓↓↓\n\(raw)\n")
        }
#endif
        
        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.unknown
        }
        guard (200..<300).contains(http.statusCode) else {
            throw NetworkError.status(http.statusCode)
        }
        
        return try Self.decoder.decode(T.self, from: data)
    }
    
    func getDecoded<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let wrapper = try await get(endpoint, as: APIResponse<T>.self)
        return wrapper.result
    }
    
    static func request<T: Decodable>(endpoint: Endpoint) async throws -> T {
        try await shared.getDecoded(endpoint)
    }
}

// MARK: - POST 요청

extension APIClient {
    func post<Body: Encodable, Resp: Decodable>(
        _ endpoint: Endpoint,
        body: Body,
        as type: Resp.Type = Resp.self
    ) async throws -> Resp {
        let url = Self.baseURL.appendingPathComponent(endpoint.path)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        authorizedRequest(&request, for: endpoint)
        
        let encoder = JSONEncoder()
        //encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .formatted(DateFormatter.yyyyMMddHHmm)
        let jsonData = try encoder.encode(body)
        
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print("📦 실제 전송 JSON:\n\(jsonString)")
        }
        
        request.httpBody = jsonData
        
        let (data, response) = try await session.data(for: request)
        
#if DEBUG
        if let raw = String(data: data, encoding: .utf8) {
            print("🔵 [POST \(endpoint.path)] Raw-Response ↓↓↓\n\(raw)\n")
        }
#endif
        
        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.unknown
        }
        guard (200..<300).contains(http.statusCode) else {
            throw NetworkError.status(http.statusCode)
        }
        
        return try Self.decoder.decode(Resp.self, from: data)
    }
}

// MARK: - PATCH 요청
extension APIClient {
    func patch<Resp: Decodable>(
        _ endpoint: Endpoint,
        as type: Resp.Type = Resp.self
    ) async throws -> Resp {
        let url = Self.baseURL.appendingPathComponent(endpoint.path)
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        authorizedRequest(&request, for: endpoint)
        
        request.httpBody = nil
        
        let (data, response) = try await session.data(for: request)
        
#if DEBUG
        if let raw = String(data: data, encoding: .utf8) {
            print("🟣 [PATCH \(endpoint.path)] Raw-Response ↓↓↓\n\(raw)\n")
        }
#endif
        
        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.unknown
        }
        guard (200..<300).contains(http.statusCode) else {
            throw NetworkError.status(http.statusCode)
        }
        
        return try Self.decoder.decode(Resp.self, from: data)
    }
}

// MARK: - Multipart 업로드

extension APIClient {
    func upload<U: Decodable>(
        _ endpoint: Endpoint,
        json: ConcertCreateRequestDTO,
        banner: Data,
        poster: Data,
        photocard: Data?
    ) async throws -> U {
        let url = Self.baseURL.appendingPathComponent(endpoint.path)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)",
                         forHTTPHeaderField: "Content-Type")
        authorizedRequest(&request, for: endpoint)
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .useDefaultKeys
        encoder.dateEncodingStrategy = .formatted(DateFormatter.yyyyMMddTHHmmss)
        let jsonData = try encoder.encode(json)
        
        
        var body = Data()
        body.appendMultiPart(field: "request", filename: "concert.json", mime: "application/json", value: jsonData, boundary: boundary)
        body.appendMultiPart(field: "banner", filename: "banner.jpg", mime: "image/jpeg", value: banner, boundary: boundary)
        body.appendMultiPart(field: "poster", filename: "poster.jpg", mime: "image/jpeg", value: poster, boundary: boundary)
        body.appendMultiPart(field: "photocardList", filename: "photocard.jpg", mime: "image/jpeg", value: photocard ?? Data(), boundary: boundary)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
#if DEBUG
        if let txt = String(data: body, encoding: .utf8) {
            print("▶︎ Multipart Body ↓↓↓\n\(txt)")
        }
#endif
        
        let (data, response) = try await session.upload(for: request, from: body)
        
        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.unknown
        }
        guard (200..<300).contains(http.statusCode) else {
            if let err = String(data: data, encoding: .utf8) {
                print("🔴 SERVER ERROR BODY:\n\(err)")
            }
            throw NetworkError.status(http.statusCode)
        }
        
#if DEBUG
        if let pretty = try? JSONSerialization.jsonObject(with: data),
           let prettyData = try? JSONSerialization.data(withJSONObject: pretty, options: .prettyPrinted),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            print("✅ 서버 응답:\n\(prettyString)")
        }
#endif
        
        return try Self.decoder.decode(U.self, from: data)
    }
}

// MARK: - multipart helper
private extension Data {
    mutating func appendMultiPart(field: String,
                                  filename: String?,
                                  mime: String,
                                  value: Data,
                                  boundary: String) {
        append("--\(boundary)\r\n".data(using: .utf8)!)
        var disposition = "Content-Disposition: form-data; name=\"\(field)\""
        if let fn = filename {
            disposition += "; filename=\"\(fn)\""
        }
        disposition += "\r\n"
        append(disposition.data(using: .utf8)!)
        append("Content-Type: \(mime)\r\n\r\n".data(using: .utf8)!)
        append(value)
        append("\r\n".data(using: .utf8)!)
    }
}

extension APIClient {
    private func authorizedRequest(_ request: inout URLRequest, for endpoint: Endpoint) {
        print("➡️ 요청 path: \(endpoint.path)")
        
        let nonAuthPaths = ["/api/auth/login", "/api/user/login"]
        if nonAuthPaths.contains(where: { endpoint.path.hasPrefix($0) }) {
            print("🚫 Authorization 헤더 제외")
            return
        }
        
        if let token = TokenManager.loadToken() {
            print("🔐 Authorization 헤더 삽입: Bearer \(token)")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }
}



