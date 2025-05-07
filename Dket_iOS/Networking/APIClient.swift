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
    
    //192.168.0.16
    private let baseURL = URL(string: "http://192.168.0.16:8080")!   //서버 이름
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
        let url = baseURL.appendingPathComponent(endpoint.path)
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
        as: Resp.Type = Resp.self
    ) async throws -> Resp {
        
        let url = baseURL.appendingPathComponent(endpoint.path)
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
        let url = baseURL.appendingPathComponent(endpoint.path)
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        let boundary = "Boundary-\(UUID().uuidString)"
        req.setValue("multipart/form-data; boundary=\(boundary)",
                     forHTTPHeaderField: "Content-Type")
        
        // —— 여기서 JSONEncoder 세팅 추가 ——
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        // 서버에서 지원하는 포맷으로 날짜를 문자열 직렬화
        encoder.dateEncodingStrategy = .formatted(DateFormatter.yyyyMMddTHHmmss)       // startDate, endDate
        // applyStart/applyEnd에는 초까지 필요하다면
        // encoder.dateEncodingStrategy = .formatted(DateFormatter.yyyyMMddTHHmmss)
        
        let jsonData = try encoder.encode(json)
        print("▶︎ JSON PART:\n\(String(data: jsonData, encoding: .utf8)!)")
        var body = Data()
        
        // ① JSON 파트
        body.appendMultiPart(field: "request",
                             filename: nil,
                             mime: "application/json",
                             value: try JSONEncoder().encode(json),
                             boundary: boundary)
        
        // ② 이미지 파트들
        body.appendMultiPart(field: "banner",
                             filename: "banner.jpg",
                             mime: "image/jpeg",
                             value: banner,
                             boundary: boundary)
        
        body.appendMultiPart(field: "poster",
                             filename: "poster.jpg",
                             mime: "image/jpeg",
                             value: poster,
                             boundary: boundary)
        
        // photocardList 파트: 이미지가 있으면 실제 파일, 없으면 빈 파트
        let pcData = photocard ?? Data()  
            body.appendMultiPart(
                field:    "photocardList",
                filename: "photocard.jpg",
                mime:     "image/jpeg",
                value:    pcData,
                boundary: boundary
            )
        
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        print("-- REQUEST TO \(url.absoluteString) --")
        if let txt = String(data: body, encoding: .utf8) {
            print(txt)
        }
        
        let (data, resp) = try await session.upload(for: req, from: body)
        guard let http = resp as? HTTPURLResponse,
              200..<300 ~= http.statusCode
        else {
            if let err = String(data: data, encoding: .utf8) {
                print("🔴 SERVER ERROR BODY:\n\(err)")
            }
            throw NetworkError.status((resp as? HTTPURLResponse)?.statusCode ?? -1)
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

