//
//  Dket_iOSApp.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/8/25.
//

import SwiftUI
import ReownWalletKit
import ReownAppKit

@main
struct Dket_iOSApp: App {
    @StateObject private var appState = AppState()
    
    init() {
        WalletConnectManager.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .onOpenURL {
                    WalletConnectManager.shared.handleDeepLink($0)
                }
                .onAppear {
                    Task {
                        // ✅ 앱 실행 시 모든 세션/페어링 초기화
                        for session in AppKit.instance.getSessions() {
                            try? await AppKit.instance.disconnect(topic: session.topic)
                        }
                        for pairing in AppKit.instance.getPairings() {
                            try? await AppKit.instance.disconnect(topic: pairing.topic)
                        }
                        print("🧹 앱 실행 시 WalletConnect 세션 및 Pairing 초기화 완료 (pending request 방지)")
                    }
                }
        }
    }
}
