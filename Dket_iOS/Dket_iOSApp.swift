//
//  Dket_iOSApp.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/8/25.
//

import SwiftUI
import ReownWalletKit

@main
struct Dket_iOSApp: App {
    @StateObject private var appState = AppState()
    
    // MARK: - 앱 실행 시 초기 설정
    init() {
        WalletConnectManager.shared.configure()
        observeWalletEvents(appState: appState)
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
}
