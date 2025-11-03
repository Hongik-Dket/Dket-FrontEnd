//
//  MetaMaskLoginView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/14/25.
//

import SwiftUI
import ReownWalletKit
import ReownAppKit

struct MetaMaskLoginView: View {
    @State private var goToRoleSelection = false
    @State private var goToSignUp = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Image("Dket")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 112.65)
                    .padding(.top, 287)
                
                Spacer()
                
                Button {
                    print("MetaMask 연결하기 버튼 클릭")
                    connectToWallet()
                } label: {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 30, height: 30)
                                .shadow(radius: 2)
                            
                            Image("MetaMaskIcon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                        }
                        .padding(.leading, 16)
                        
                        Spacer()
                        
                        Text("MetaMask로 로그인하기")
                            .font(.system(size: 16, weight: .bold))
                            .padding(.trailing, 90)
                    }
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(Color(red: 246/255, green: 133/255, blue: 29/255))
                    .foregroundColor(.white)
                    .cornerRadius(5)
                    .padding(.horizontal, 30)
                }
                .padding(.bottom, 16)
                
                Button {
                    print("회원가입 버튼 클릭")
                    goToSignUp = true
                } label: {
                    Text("회원가입")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                        .underline()
                }
                .padding(.bottom, 80)
                
                // MARK: - 네비게이션 이동
                NavigationLink(destination: SignUpNationalityView(), isActive: $goToSignUp) { EmptyView() }
                
            }
        }
    }
    
    func connectToWallet() {
        Task {
            do {
                await resetSession()
                
                let uri = try await AppKit.instance.connect(walletUniversalLink: nil)
                
                print("📡 WalletConnect URI 생성됨")
                
                let base = "https://metamask.app.link/wc?uri="
                guard let encoded = uri?.absoluteString.addingPercentEncoding(
                    withAllowedCharacters: .alphanumerics),
                      let url = URL(string: base + encoded) else {
                    print("❗ URI 인코딩 실패")
                    return
                }
                
                DispatchQueue.main.async {
                    UIApplication.shared.open(url)
                }
                
            } catch {
                print("❌ 연결 실패:", error)
            }
        }
    }
    
    func resetSession() async {
        let sessions = AppKit.instance.getSessions()
        for session in sessions {
            try? await AppKit.instance.disconnect(topic: session.topic)
        }
        print("🧹 기존 세션 정리 완료")
    }
}


