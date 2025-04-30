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
    
    // 👉 한곳에서만 날짜 포맷을 판단하도록 공용 decoder 제공
    private static let _decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        d.dateDecodingStrategy = .custom { dec in
            let c = try dec.singleValueContainer()
            let s = try c.decode(String.self)
            if let d = DateFormatter.yyyyMMdd.date(from: s) { return d }
            if let d = DateFormatter.yyyyMMddHHmmss.date(from: s) { return d }
            if let d = DateFormatter.yyyyMMddTHHmmss.date(from: s) { return d }
            throw DecodingError.dataCorruptedError(in: c,
                                                   debugDescription: "지원하지 않는 날짜 형식 \(s)")
        }
        return d
    }()
    
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
        
        guard let http = resp as? HTTPURLResponse,
              200..<300 ~= http.statusCode else {
            throw NetworkError.status((resp as? HTTPURLResponse)?.statusCode ?? -1)
        }
        return try APIClient._decoder.decode(T.self, from: data)
    }
}


extension APIClient {
    
    /// 제네릭 POST (JSON Body)
    func post<Body: Encodable, Resp: Decodable>(
        _ endpoint: Endpoint,
        body: Body,
        as type: Resp.Type = Resp.self
    ) async throws -> Resp {
        
        guard let url = URL(string: endpoint.path, relativeTo: baseURL) else {
            throw NetworkError.invalidURL
        }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .formatted(DateFormatter.yyyyMMddHHmm)
        req.httpBody = try encoder.encode(body)
        
        let (data, resp) = try await session.data(for: req)
        
        #if DEBUG
        if let raw = String(data: data, encoding: .utf8) {
            print("🔵 [POST \(endpoint.path)] Raw-Response ↓↓↓\n\(raw)\n")
        }
        #endif
        
        guard let http = resp as? HTTPURLResponse,
              200..<300 ~= http.statusCode
        else { throw NetworkError.status((resp as? HTTPURLResponse)?.statusCode ?? -1) }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .formatted(DateFormatter.yyyyMMddHHmm)
        return try decoder.decode(Resp.self, from: data)
    }
    
    /// multipart/form-data 업로드
    func upload<U: Decodable>(
        _ endpoint: Endpoint,
        json: EventCreateRequestDTO,
        banner: Data, poster: Data, photocard: Data?
    ) async throws -> U {
        
        let boundary = "Boundary-\(UUID().uuidString)"
        guard let url = URL(string: endpoint.path, relativeTo: baseURL) else {
            throw NetworkError.invalidURL
        }
        
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("multipart/form-data; boundary=\(boundary)",
                     forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // ① JSON 파트
        body.appendMultiPart(field: "request",
                             filename: nil,
                             mime: "application/json",
                             value: try JSONEncoder().encode(json),
                             boundary: boundary)
        
        // ② 이미지 파트들
        body.appendMultiPart(field: "bannerImage",
                             filename: "banner.jpg",
                             mime: "image/jpeg",
                             value: banner,
                             boundary: boundary)
        
        body.appendMultiPart(field: "posterImage",
                             filename: "poster.jpg",
                             mime: "image/jpeg",
                             value: poster,
                             boundary: boundary)
        
        if let pc = photocard {
            body.appendMultiPart(field: "photocardImage",
                                 filename: "photocard.jpg",
                                 mime: "image/jpeg",
                                 value: pc,
                                 boundary: boundary)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        req.httpBody = body
        
        let (data, resp) = try await session.upload(for: req, from: body)
        guard let http = resp as? HTTPURLResponse,
              200..<300 ~= http.statusCode else {
            throw NetworkError.invalidURL
        }
        return try JSONDecoder().decode(U.self, from: data)
    }
}

/// multipart helper
private extension Data {
    mutating func appendMultiPart(field: String,
                                  filename: String?,
                                  mime: String,
                                  value: Data,
                                  boundary: String) {
        
        append("--\(boundary)\r\n".data(using: .utf8)!)
        if let filename {
            append("Content-Disposition: form-data; name=\"\(field)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
            append("Content-Type: \(mime)\r\n\r\n".data(using: .utf8)!)
        } else {
            append("Content-Disposition: form-data; name=\"\(field)\"\r\n\r\n".data(using: .utf8)!)
        }
        append(value)
        append("\r\n".data(using: .utf8)!)
    }
}

