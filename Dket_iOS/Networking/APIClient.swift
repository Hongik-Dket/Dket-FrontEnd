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

    private let baseURL = URL(string: "http://192.168.198.228:8080")! // 수정된 유효한 주소
    private let session = URLSession.shared

    // 공통 디코더
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
        let url = baseURL.appendingPathComponent(endpoint.path)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

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

        do {
            return try APIClient.decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decoding(error)
        }
    }

    /// APIResponse<T>용 해석기 (T만 꺼냄)
    func getDecoded<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let wrapper = try await get(endpoint, as: APIResponse<T>.self)
        return wrapper.result
    }
}

// MARK: - POST 요청

extension APIClient {
    func post<Body: Encodable, Resp: Decodable>(
        _ endpoint: Endpoint,
        body: Body,
        as type: Resp.Type = Resp.self
    ) async throws -> Resp {
        let url = baseURL.appendingPathComponent(endpoint.path)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .formatted(DateFormatter.yyyyMMddHHmm)
        request.httpBody = try encoder.encode(body)

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

        do {
            return try APIClient.decoder.decode(Resp.self, from: data)
        } catch {
            throw NetworkError.decoding(error)
        }
    }
}

// MARK: - Multipart 업로드

extension APIClient {
    func upload<U: Decodable>(
        _ endpoint: Endpoint,
        json: EventCreateRequestDTO,
        banner: Data,
        poster: Data,
        photocard: Data?
    ) async throws -> U {
        let url = baseURL.appendingPathComponent(endpoint.path)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)",
                         forHTTPHeaderField: "Content-Type")

        // ① JSON 파트
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .formatted(DateFormatter.yyyyMMddTHHmmss)
        let jsonData = try encoder.encode(json)

        var body = Data()
        body.appendMultiPart(field: "request", filename: nil, mime: "application/json", value: jsonData, boundary: boundary)

        // ② 이미지 파트들
        body.appendMultiPart(field: "banner", filename: "banner.jpg", mime: "image/jpeg", value: banner, boundary: boundary)
        body.appendMultiPart(field: "poster", filename: "poster.jpg", mime: "image/jpeg", value: poster, boundary: boundary)

        // ③ 포토카드 (있으면 첨부, 없으면 빈 파트라도 생성)
        body.appendMultiPart(field: "photocardList", filename: "photocard.jpg", mime: "image/jpeg", value: photocard ?? Data(), boundary: boundary)

        // ④ 마지막 바운더리 닫기
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

        do {
            return try APIClient.decoder.decode(U.self, from: data)
        } catch {
            throw NetworkError.decoding(error)
        }
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
        var disposition = "Content-Disposition: form-data; name=\"\(field)\""
        if let fn = filename {
            disposition += "; filename=\"\(fn)\""
        }
        disposition += "\r\n"
        append(disposition.data(using: .utf8)!)
        
        // 3) Content-Type (파일이든 JSON이든 반드시)
        append("Content-Type: \(mime)\r\n\r\n".data(using: .utf8)!)
        
        // 4) 실제 데이터
        append(value)
        
        // 5) 파트 구분
        append("\r\n".data(using: .utf8)!)
    }
}

