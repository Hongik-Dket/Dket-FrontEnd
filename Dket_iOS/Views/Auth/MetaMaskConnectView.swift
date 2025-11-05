//
//  MetaMaskConnectView.swift
//  Dket_iOS
//
//  Created by M-136 on 11/3/25.
//

import SwiftUI
import ReownWalletKit
import ReownAppKit

struct MetaMaskConnectView: View {
    @EnvironmentObject var appState: AppState
    @State private var isConnecting = false
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

                // MARK: - MetaMask 연결 버튼
                Button {
                    print("🦊 MetaMask 연결 버튼 클릭 (회원가입 후)")
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

                        Text(isConnecting ? "연결 중..." : "MetaMask로 연결하기")
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
                .padding(.bottom, 80)

                NavigationLink(destination: RoleSelectionView(), isActive: $appState.isLoggedIn) { EmptyView() }
            }
            .navigationBarBackButtonHidden(true)
            .alert("알림", isPresented: $showAlert) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                observeWalletEvents(appState: appState, mode: .signupComplete)
            }
        }
    }
}

// MARK: - WalletConnect 연결 로직
extension MetaMaskConnectView {
    func connectToWallet() {
        Task {
            do {
                isConnecting = true
                await resetSession()

                let uri = try await AppKit.instance.connect(walletUniversalLink: nil)
                print("📡 WalletConnect URI 생성됨:", uri?.absoluteString ?? "nil")

                // ✅ 인코딩 복원: alphanumerics
                guard let encoded = uri?.absoluteString.addingPercentEncoding(withAllowedCharacters: .alphanumerics),
                      let url = URL(string: "https://metamask.app.link/wc?uri=" + encoded)
                else {
                    print("❗ URI 인코딩 실패")
                    return
                }

                print("🌐 MetaMask로 이동:", url)
                DispatchQueue.main.async {
                    UIApplication.shared.open(url)
                }

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
        print("🧹 기존 세션 및 Pairing 정리 완료 (회원가입 후 연결용)")
    }
}
