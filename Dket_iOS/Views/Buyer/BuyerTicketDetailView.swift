//
//  TicketDetailView.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/14/25.
//

import SwiftUI

struct BuyerTicketDetailView: View {
    @StateObject private var vm: BuyerTicketDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showPhotoCard = false
    @State private var showResaleView = false
    @State private var selectedTicket: BuyerTicketDetail? = nil
    @State private var showPhotoFullScreen = false
    @State private var showQRView = false
    @State private var qrCodeUrl: String? = nil
    @State private var identityType: String? = nil
    
    // 새 상태
    @State private var isOwnershipProofProcessing = false
    @State private var showOwnershipProofFailedAlert = false
    
    let sessionId: Int64?
    
    // MARK: - 일반 조회용 (sessionId 없음)
    init(ticketId: Int64) {
        self.sessionId = nil
        _vm = StateObject(wrappedValue: BuyerTicketDetailViewModel(ticketId: ticketId))
    }
    
    // MARK: - 입장 인증용 (sessionId 있음)
    init(ticketId: Int64, sessionId: Int64) {
        self.sessionId = sessionId
        _vm = StateObject(wrappedValue: BuyerTicketDetailViewModel(ticketId: ticketId))
    }

    var body: some View {
        ZStack {
            Image("TicketDetail")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            if let ticket = vm.ticket {
                VStack(spacing: 12) {
                    // 상단 제목 버튼
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            dismiss()
                        }
                    }) {
                        Text(ticket.concertTitle)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.dketBlue)
                            .underline()
                            .padding(.top, 120)
                    }
                    .buttonStyle(.plain)

                    // 티켓 정보
                    VStack(alignment: .leading, spacing: 10) {
                        TicketInfoRow(label: "공연 일시", value: ticket.startDateFormatted)
                        TicketInfoRow(label: "예매자 명", value: ticket.buyerName)
                        TicketInfoRow(label: "생년월일", value: ticket.birthDateFormatted)
                        TicketInfoRow(label: "티켓 번호", value: ticket.ticketNumber)
                        TicketInfoRow(label: "좌석 번호", value: ticket.seatNumber)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 50)
                    .padding(.top, 20)

                    // 포토카드
                    if let url = URL(string: ticket.photoCardUrl) {
                        VStack(spacing: 16) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 260, height: 260)
                                    .cornerRadius(8)
                                    .shadow(radius: 4)
                                    .padding(.top, 12)
                            } placeholder: {
                                ProgressView()
                                    .frame(width: 260, height: 260)
                                    .padding(.top, 12)
                            }
                            .onTapGesture { showPhotoFullScreen = true }

                            if let nftUrl = URL(string: ticket.nftUrl) {
                                Button(action: { UIApplication.shared.open(nftUrl) }) {
                                    Text("NFT 확인하기 →")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.dketBlue)
                                        .underline()
                                }
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.trailing, 25)
                            }
                        }
                        .fullScreenCover(isPresented: $showPhotoFullScreen) {
                            FullScreenPhotoView(imageUrl: ticket.photoCardUrl) {
                                showPhotoFullScreen = false
                            }
                        }
                    }

                    Spacer()

                    // 하단 버튼
                    VStack(spacing: 16) {
                        CircleButton(title: "판매하기") {
                            selectedTicket = ticket
                            showResaleView = true
                        }
                        .disabled(!isSellButtonEnabled)
                        .opacity(isSellButtonEnabled ? 1 : 0.4)

                        CircleButton(title: "입장하기") {
                            Task {
                                await handleEnterProof(for: ticket)
                            }
                        }
                        .disabled(!isEnterButtonEnabled)
                        .opacity(isEnterButtonEnabled ? 1 : 0.4)
                    }
                    .padding(.bottom, 50)
                }

                // 닫기(X) 버튼
                VStack {
                    HStack {
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.black)
                                .padding(10)
                                .background(Color.white.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .padding(.top, 50)
                        .padding(.trailing, 20)
                    }
                    Spacer()
                }
            } else {
                ProgressView()
            }
        }
        .task { await vm.fetch() }
        .fullScreenCover(isPresented: $showResaleView) {
            ResaleRegisterView(ticket: selectedTicket ?? vm.ticket!)
        }
        
        .fullScreenCover(isPresented: $showQRView) {
            if let ticket = vm.ticket, let qr = qrCodeUrl, let idType = identityType {
                BuyerProofQRView(ticket: ticket, qrCodeUrl: qr, identityType: idType)
            }
        }
        .overlay {
            ZStack {
                if isOwnershipProofProcessing {
                    ProofProgressAlertView(
                        title: "티켓 소유 인증 절차를 진행 중입니다.",
                        message: "완료까지 약 1분 정도 소요됩니다."
                    )
                }

                if showOwnershipProofFailedAlert {
                    ProofFailedAlertView(
                        title: "유효하지 않은 티켓입니다.",
                        message: "해당 티켓으로는 입장이 불가합니다.",
                        retryButtonTitle: "다시 입력하기",
                        onRetry: { showOwnershipProofFailedAlert = false },
                        onClose: { showOwnershipProofFailedAlert = false }
                    )
                }
            }
        }
    }

    // MARK: - 입장 로직
    private func handleEnterProof(for ticket: BuyerTicketDetail) async {
        await MainActor.run { isOwnershipProofProcessing = true }

        do {
            // ① 챌린지 요청
            let challenge = try await ProofService.shared.requestOwnChallenge(ticketId: ticket.ticketId)
            print("챌린지 수신: \(challenge.challengeId)")

            // ② Face ID 서명
            let signatureData = try await BiometricKeyManager.shared.sign(challenge: challenge.challenge)
            let signatureHex = signatureData.toHexString()

            // 공개키 압축
            let privateKey = try BiometricKeyManager.shared.loadOrCreateKeyPair()
            let pubKeyData = try BiometricKeyManager.shared.getPublicKeyData(from: privateKey)
            guard let compressedKey = BiometricKeyManager.shared.compressPublicKey(pubKeyData) else {
                throw NSError(domain: "FaceID", code: -99,
                              userInfo: [NSLocalizedDescriptionKey: "공개키 압축 실패"])
            }

            // ③ 서버로 증명 전송
            let proofResponse = try await ProofService.shared.submitOwnProof(
                sessionId: ticket.sessionId,
                challengeId: challenge.challengeId,
                signature: signatureHex,
                publicKey: compressedKey.toHexString()
            )

            // ④ QR 화면 전환
            await MainActor.run {
                isOwnershipProofProcessing = false
                qrCodeUrl = proofResponse.qrCodeUrl
                identityType = proofResponse.identityType
                showQRView = true
            }

        } catch {
            print("❌ 소유 증명 실패: \(error)")

            await MainActor.run {
                isOwnershipProofProcessing = false
            }

            // ✅ 서버 오류 처리
            if let apiError = error as? APIErrorResponse {
                let code = apiError.code

                // 조작/유효하지 않은 티켓 관련 에러
                if code.hasPrefix("ZKP_4002") ||
                   code.hasPrefix("ZKP_4003") ||
                   code.hasPrefix("ZKP_4004") ||
                   code.hasPrefix("OWN_4002") ||
                   code.hasPrefix("OWN_4003") ||
                   code.hasPrefix("SIG_") {
                    await MainActor.run {
                        showOwnershipProofFailedAlert = true
                    }
                    return
                }

                // 서버측 에러 (500번대 or 기타 예외)
                if code.hasPrefix("COMMON_500") ||
                   code.hasPrefix("ZKP_500") ||
                   code.hasPrefix("IMAGE_500") ||
                   code.hasPrefix("BLOCKCHAIN_500") {
                    await MainActor.run {
                        NavigationUtil.presentFullScreen(PassportErrorView())
                    }
                    return
                }
            }

            // 예외 케이스 — 네트워크 실패 등
            await MainActor.run {
                showOwnershipProofFailedAlert = true
            }
        }
    }
}

struct TicketInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .foregroundColor(.black)
                .font(.system(size: 14, weight: .medium))
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .multilineTextAlignment(.leading)
        }
    }
}

struct FullScreenPhotoView: View {
    let imageUrl: String
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            AsyncImage(url: URL(string: imageUrl)) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } placeholder: {
                ProgressView()
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .padding(.top, 40)
                    .padding(.trailing, 20)
                }
                Spacer()
            }
        }
    }
}

extension BuyerTicketDetailView {
    private var isConcertToday: Bool {
        guard let ticket = vm.ticket else { return false }
        let calendar = Calendar.current
        return calendar.isDateInToday(ticket.concertDateTime)
    }
    
    private var isSellButtonEnabled: Bool {
        guard let ticket = vm.ticket else { return false }
        // ① 아직 리세일 등록 안됨
        if !ticket.isResaleListed { return true }
        // ② 이미 리세일 중인데 공연 전 → 비활성화
        if ticket.isResaleListed && !isConcertToday { return false }
        // ③ 리세일 중인데 공연 당일 → 비활성화
        if ticket.isResaleListed && isConcertToday { return false }
        return false
    }
    
    private var isEnterButtonEnabled: Bool {
        guard let ticket = vm.ticket else { return false }
        // 리세일 중이고 공연 당일에만 활성화
        return !ticket.isEntered && isConcertToday
    }
}




enum NavigationUtil {
    static func presentFullScreen<Content: View>(_ view: Content) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        let hosting = UIHostingController(rootView: view)
        hosting.modalPresentationStyle = .fullScreen
        window.rootViewController?.present(hosting, animated: true)
    }
}
