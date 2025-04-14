//
//  LoginView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/8/25.
//

import SwiftUI

struct LoginView: View {
    @State private var goToMetaMaskLogin = false
    
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
                
                // 카카오로 시작하기 버튼
                Button {
                    goToMetaMaskLogin = true
                } label: {
                    HStack {
                        Image(systemName: "message.fill")
                            .padding(.leading, 25)
                        Spacer()
                        Text("5초 만에 카카오로 시작하기")
                            .font(.system(size: 16, weight: .bold))
                            .padding(.trailing, 60)
                    }
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(Color(red: 251/255, green: 228/255, blue: 78/255))
                    .foregroundColor(.black)
                    .cornerRadius(5)
                    .padding(.horizontal,30)
                }
                .padding(.bottom, 80)
                // 메타마스크 로그인 페이지로 연결
                NavigationLink(destination: MetaMaskLoginView(), isActive: $goToMetaMaskLogin) {
                    EmptyView()
                }
            }
        }
    }
}


struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
