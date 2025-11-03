//
//  ResaleView.swift
//  Dket_iOS
//
//  Created by M-136 on 9/30/25.
//

import SwiftUI

struct ResaleRegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: ResaleRegisterViewModel
    
    @State private var showAlertModal = false
    
    init(ticket: TicketDetail) {
        _vm = StateObject(wrappedValue: ResaleRegisterViewModel(ticket: ticket))
    }
    
    var ticketPrice: Int { vm.ticket.price }
    var maxPrice: Int? {
        // entered가 false면 상한 120%, true면 nil
        vm.ticket.isEntered ? nil : Int(Double(ticketPrice) * 1.2)
    }
    
    var resalePriceInt: Int? { Int(vm.priceText) }
    
    var isPriceValid: Bool {
        guard let resale = resalePriceInt else { return false }
        
        if vm.ticket.isEntered {
            return resale >= ticketPrice
        } else {
            // 아직 입장 전이면 120% 상한 적용
            guard let max = maxPrice else { return false }
            return resale >= ticketPrice && resale <= max
        }
    }
    
    var contribution: Int {
        guard let resale = resalePriceInt else { return 0 }
        return max(0, resale - ticketPrice) / 10
    }
    
    var finalRevenue: Int {
        guard let resale = resalePriceInt else { return ticketPrice }
        return resale - contribution
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("판매 등록")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top)
                    
                    // MARK: - 티켓 정보
                    CustomBox(title: "티켓 정보") {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 6) {
                                TextRow(title: "공연명", value: vm.ticket.concertTitle)
                                TextRow(title: "공연 일시", value: vm.ticket.startDateFormatted)
                                TextRow(title: "예매자 명", value: vm.ticket.buyerName)
                                TextRow(title: "생년월일", value: vm.ticket.birthDateFormatted)
                                TextRow(title: "티켓 번호", value: vm.ticket.ticketNumber)
                                TextRow(title: "좌석 번호", value: vm.ticket.seatNumber)
                            }
                            Spacer()
                            AsyncImage(url: URL(string: vm.ticket.photoCardUrl)) { image in
                                image.resizable().aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Color.gray.opacity(0.2)
                            }
                            .frame(width: 90, height: 110)
                            .clipped()
                            .cornerRadius(8)
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // MARK: - 판매 정보
                    CustomBox(title: "판매 정보") {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("티켓 정가")
                                Spacer()
                                Text("\(ticketPrice.formatted()) 원")
                            }
                            .font(.subheadline)
                            
                            HStack {
                                Text("판매가")
                                Spacer()
                                TextField("판매가 입력", text: $vm.priceText)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 100)
                                    .textFieldStyle(.roundedBorder)
                                Text("원")
                            }
                            .font(.subheadline)
                            
                            HStack {
                                Text("공연 기여금")
                                Spacer()
                                Text("-\(contribution.formatted()) 원")
                            }
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            
                            Divider()
                            
                            HStack {
                                Text("최종 수익")
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("\(finalRevenue.formatted()) 원")
                                    .foregroundColor(.dketBlue)
                                    .fontWeight(.bold)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // MARK: - 판매 규정
                    CustomBox(title: "판매 규정") {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("• 판매가는 티켓 정가의 최대 120%까지 설정할 수 있습니다.")
                            Text("• 공연 기여금은 판매가에서 티켓 정가를 뺀 금액의 10%이며, 이는 공연 개최자에게 돌아갑니다.")
                            Text("• 위 규정은 입장 마감 전까지 적용됩니다.")
                            Text("• 입장 마감 이후에는 가격 상한 제한이 없으며, 공연 기여금은 판매가의 10%로 책정됩니다.")
                        }
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.vertical, 8)
                    }
                    
                    // MARK: - 판매하기 버튼
                    CircleButton(
                        title: "판매하기",
                        action: {
                            showAlertModal = true
                        },
                        isDisabled: !isPriceValid
                    )
                    .padding(.top)
                }
                .padding()
            }
            
            // MARK: - 로딩 상태
            if vm.isLoading {
                Color.black.opacity(0.3).ignoresSafeArea()
                ProgressView("등록 중...")
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
            }
            
            // MARK: - ResaleSuccessAlert 표시
            if showAlertModal {
                ResaleSuccessAlert(
                    onConfirm: {
                        Task {
                            // Alert의 판매하기 버튼 → 서버 요청
                            await vm.registerResale()
                            showAlertModal = false
                        }
                    },
                    onClose: {
                        showAlertModal = false
                    }
                )
                .transition(.opacity)
                .animation(.easeInOut, value: showAlertModal)
            }
        }
        // MARK: - Alert 처리
        .alert("판매 등록 완료", isPresented: $vm.showSuccessAlert) {
            Button("확인") { dismiss() }
        } message: {
            Text("리세일 마켓에 티켓이 등록되었습니다.")
        }
        .alert("오류", isPresented: $vm.showErrorAlert) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(vm.errorMessage ?? "알 수 없는 오류가 발생했습니다.")
        }
        .onChange(of: vm.shouldTriggerOnChain) { triggered in
            if triggered, let tokenId = vm.tokenId,
               let walletAddress = UserWalletStore.shared.address {
                Task {
                    do {
                        print("서버 등록 성공 → 온체인 approve 실행 (tokenId: \(tokenId))")
                        try await ApproveNFTService().sendApproveTransaction(tokenId: tokenId, from: walletAddress)
                        
                        // MetaMask로 전환
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            if let url = URL(string: "metamask://"), UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            }
                        }
                        
                        print("온체인 Approve 성공")
                    } catch {
                        print("❌ Approve 트랜잭션 실패: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}

private struct TextRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(title)
                .foregroundColor(.gray)
                .frame(width: 80, alignment: .leading)
            Text(value)
            
        }
        .font(.system(size: 14))
    }
}

extension Int {
    func formattedWithSeparator() -> String {
        NumberFormatter.localizedString(from: NSNumber(value: self), number: .decimal)
    }
}

struct ResaleView_Previews: PreviewProvider {
    static var previews: some View {
        ResaleRegisterView(
            ticket: TicketDetail(
                ticketId: 123,
                concertTitle: "공연이름~~~",
                concertDateTime: ISO8601DateFormatter().date(from: "2025-03-10T18:00:00") ?? Date(),
                buyerName: "여희주",
                birth: ISO8601DateFormatter().date(from: "2003-02-25T00:00:00") ?? Date(),
                ticketNumber: "T152670849345203",
                seatNumber: "39",
                nftUrl: "",
                isEntered: false,
                photoCardUrl: "https://via.placeholder.com/100", // 이미지 URL 대체
                price: 189000, isResaleListed: true
            )
        )
    }
}

struct CustomBox<Content: View>: View {
    let title: String
    let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .padding(.bottom, 4)
            
            content()
        }
        .padding()
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(8)
    }
}
