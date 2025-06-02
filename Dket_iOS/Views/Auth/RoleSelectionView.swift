//
//  RoleSelectionView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/14/25.
//

import SwiftUI

struct RoleSelectionView: View {
    @State private var goToHostHome = false
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationStack {
            VStack {
                Image("Dket")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 112.65)
                    .padding(.top, 287)
                
                Spacer()
                
                VStack(spacing: 10) {
                    // 개최자 버튼
                    Button {
                        appState.userRole = .host
                        appState.isLoggedIn = true
                    } label: {
                        Text("개최자")
                            .font(.system(size: 16, weight: .bold))
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(Color(red: 22/255, green: 29/255, blue: 111/255))
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }
                    
                    // 구매자 버튼
                    Button {
                        appState.userRole = .buyer
                        appState.isLoggedIn = true
                        
                    } label: {
                        Text("구매자")
                            .font(.system(size: 16, weight: .bold))
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(Color(red: 22/255, green: 29/255, blue: 111/255))
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
                
                // HostHomeView로 이동.
                NavigationLink(destination: HostHomeView(), isActive: $goToHostHome) {
                    EmptyView()
                }
            }
        }
    }
}

struct RoleSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        RoleSelectionView().environmentObject(AppState())
    }
}
