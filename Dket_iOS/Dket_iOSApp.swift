//
//  Dket_iOSApp.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/8/25.
//

import SwiftUI

@main
struct Dket_iOSApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
}
