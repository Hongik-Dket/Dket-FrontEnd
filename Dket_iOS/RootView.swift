//
//  RootView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/14/25.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appState: AppState
    var body: some View {
        Group {
            if !appState.isLoggedIn {
                MetaMaskLoginView()
            } else if appState.userRole == nil {
                RoleSelectionView()
            } else if appState.userRole == .host {
                HostHomeView()
            } else {
                BuyerHomeView()
            }
        }
        .animation(.easeInOut, value: appState.isLoggedIn)
        .animation(.easeInOut, value: appState.userRole)
    }
}
