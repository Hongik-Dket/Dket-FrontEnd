//
//  MetaMaskLoginView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/14/25.
//

import SwiftUI

struct MetaMaskLoginView: View {
    @State private var goToRoleSelection = false
    
    var body: some View {
        NavigationStack {
            VStack {
                // DKet 로고 이미지
                Image("Dket")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 112.65)
                    .padding(.top, 287)
                
                Spacer()
                
                // 메타마스크로 시작하기 버튼
                Button {
                    goToRoleSelection = true
                } label: {
                    HStack {
                        Image(systemName: "message.fill")
                            .padding(.leading, 25)
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                        Spacer()
                        Text("MetaMask 연결하기")
                            .font(.system(size: 16, weight: .bold))
                            .padding(.trailing, 60)
                    }
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(Color(red: 246/255, green: 133/255, blue: 29/255))
                    .foregroundColor(.white)
                    .cornerRadius(5)
                    .padding(.horizontal,30)
                }
                .padding(.bottom, 80)
                
                // RoleSelectionView 연결
                NavigationLink(destination: RoleSelectionView(), isActive: $goToRoleSelection) {
                    EmptyView()
                }
            }
        }
    }
}

struct MetaMaskLoginView_Previews: PreviewProvider {
    static var previews: some View {
        MetaMaskLoginView()
    }
}


