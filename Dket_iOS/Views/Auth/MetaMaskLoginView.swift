//
//  MetaMaskLoginView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/14/25.
//

import SwiftUI
import ReownWalletKit
import ReownAppKit

import SwiftUI

struct MetaMaskLoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var isConnecting = false
    @State private var goToSignUp = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Image("Dket")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 112.65)
                    .padding(.top, 287)
                Spacer()

                Button {
                    print("🦊 MetaMask 로그인 버튼 클릭")
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
                        Text(isConnecting ? "연결 중..." : "MetaMask로 로그인하기")
                            .font(.system(size: 16, weight: .bold))
                            .padding(.trailing, 90)
                    }
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(Color(red: 246/255, green: 133/255, blue: 29/255))
                    .foregroundColor(.white)
                    .cornerRadius(5)
                    .padding(.horizontal, 30)
                }
                .disabled(isConnecting)
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

                NavigationLink(destination: SignUpNationalityView(), isActive: $goToSignUp) { EmptyView() }
                NavigationLink(destination: RoleSelectionView(), isActive: $appState.isLoggedIn) { EmptyView() }
            }
            .navigationBarBackButtonHidden(true)
            .alert("알림", isPresented: $showAlert) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }

    func connectToWallet() {
        Task {
            do {
                isConnecting = true
                await resetSession()

                // observe는 버튼 눌렀을 때만 등록
                observeWalletEvents(appState: appState)

                let uri = try await AppKit.instance.connect(walletUniversalLink: nil)
                print("📡 WalletConnect URI 생성됨:", uri?.absoluteString ?? "nil")

                guard let encoded = uri?.absoluteString.addingPercentEncoding(withAllowedCharacters: .alphanumerics),
                      let url = URL(string: "https://metamask.app.link/wc?uri=" + encoded)
                else {
                    print("❗ URI 인코딩 실패")
                    return
                }

                print("🌐 MetaMask로 이동:", url)
                DispatchQueue.main.async { UIApplication.shared.open(url) }
            } catch {
                print("❌ MetaMask 연결 실패:", error.localizedDescription)
                alertMessage = "MetaMask 연결 중 오류가 발생했습니다."
                showAlert = true
            }
            isConnecting = false
        }
    }

    func resetSession() async {
        for session in AppKit.instance.getSessions() {
            try? await AppKit.instance.disconnect(topic: session.topic)
        }
        for pairing in AppKit.instance.getPairings() {
            try? await AppKit.instance.disconnect(topic: pairing.topic)
        }
        print("🧹 기존 세션 및 Pairing 정리 완료 (로그인용)")
    }
}
