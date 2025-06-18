//
//  DefaultSocketFactory.swift
//  Dket_iOS
//
//  Created by 이지우 on 5/25/25.
//

import Foundation
import WalletConnectRelay

final class CustomWebSocket: WalletConnectRelay.WebSocketConnecting {
    var isConnected: Bool = false

    var onConnect: (() -> Void)?
    var onDisconnect: ((Error?) -> Void)?
    var onText: ((String) -> Void)?

    var request: URLRequest

    private var webSocketTask: URLSessionWebSocketTask?
    private let session = URLSession(configuration: .default)

    init(url: URL) {
        self.request = URLRequest(url: url)
    }

    func connect() {
        webSocketTask = session.webSocketTask(with: request)
        webSocketTask?.resume()
        isConnected = true
        listen()
        onConnect?()
    }

    func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        isConnected = false
        onDisconnect?(nil)
    }

    func write(string: String, completion: (() -> Void)?) {
        webSocketTask?.send(.string(string)) { error in
            if let error = error {
                self.onDisconnect?(error)
            } else {
                completion?()
            }
        }
    }

    private func listen() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                if case .string(let text) = message {
                    self?.onText?(text)
                }
                self?.listen()
            case .failure(let error):
                self?.onDisconnect?(error)
            }
        }
    }
}

final class DefaultSocketFactory: WalletConnectRelay.WebSocketFactory {
    func create(with url: URL) -> any WalletConnectRelay.WebSocketConnecting {
        return CustomWebSocket(url: url)
    }
}
