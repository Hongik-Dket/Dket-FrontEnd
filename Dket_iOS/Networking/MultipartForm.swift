//
//  MultipartForm.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/30/25.
//

import Foundation

struct MultipartForm {
    private let boundary = "DKET-\(UUID().uuidString)"

    private var body = Data()

    mutating func addField(name: String, value: String) {
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n")
        body.append("\(value)\r\n")
    }

    mutating func addFile(name: String, filename: String, mime: String, data: Data) {
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n")
        body.append("Content-Type: \(mime)\r\n\r\n")
        body.append(data)
        body.append("\r\n")
    }

    mutating func finalize() {
        body.append("--\(boundary)--\r\n")
    }

    func asRequestBody() -> (Data, String) {
        return (body, boundary)
    }
}

// String → Data helper
private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) { append(data) }
    }
}
