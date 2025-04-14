//
//  RootView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/14/25.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        if appState.isLoggedIn {
            if appState.userRole == .host {
                HostHomeView()
            } else if appState.userRole == .buyer {
                BuyerHomeView()
            }
        } else {
            LoginView()
        }
    }
}
