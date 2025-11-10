//
//  ResaleTicketView.swift
//  Dket_iOS
//
//  Created by M-136 on 9/30/25.
//

import SwiftUI


struct ResalePurchaseView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    @StateObject private var vm: ResalePurchaseViewModel
    @State private var showMyPage = false
    
    init(resaleId: Int64) {
        _vm = StateObject(wrappedValue: ResalePurchaseViewModel(resaleId: resaleId))
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                BackHeaderView(
                    title: "구매",
                    useLogo: false,
                    onBack: { dismiss() },
                    onMenu: { showMyPage = true }
                )
                
                ScrollView {
                    if vm.isLoading {
                        ProgressView("불러오는 중...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let info = vm.ticketInfo {
                        VStack(alignment: .leading, spacing: 28) {
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("티켓 정보")
                                    .font(.system(size: 18, weight: .bold))
                                    .padding(.bottom, 2)
                                
                                HStack(alignment: .top, spacing: 16) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        InfoTextRow(label: "공연명", value: info.concertTitle)
                                        InfoTextRow(label: "공연 장소", value: info.location)
                                        InfoTextRow(label: "공연 일시", value: "\(info.date) \(info.startTime)")
                                        InfoTextRow(label: "좌석 번호", value: info.seatCode)
                                    }
                                    
                                    Spacer()
                                    
                                    AsyncImage(url: info.photoCardUrl) { image in
                                        image.resizable()
                                            .scaledToFill()
                                            .frame(width: 83, height: 127)
                                            .cornerRadius(8)
                                            .clipped()
                                    } placeholder: {
                                        Color.gray.opacity(0.2)
                                            .frame(width: 83, height: 127)
                                            .cornerRadius(8)
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
                            }
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("구매 정보")
                                    .font(.system(size: 18, weight: .bold))
                                    .padding(.bottom, 2)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    InfoTextRow(label: "티켓 정가", value: info.originalPrice.formattedKrw)
                                    InfoTextRow(label: "구매가", value: info.priceKrw.formattedKrw)
                                    InfoTextRow(label: "결제 금액", value: info.priceWei.formattedEth, valueColor: .dketBlue)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("구매 규정")
                                    .font(.system(size: 18, weight: .bold))
                                    .padding(.bottom, 2)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    RuleText("결제는 요청 후 수분 내에 처리됩니다.")
                                    RuleText("구매 요청 후 취소는 불가능합니다.")
                                    RuleText("거래된 티켓은 MY 티켓 및 MY 포토카드에 자동으로 등록됩니다.")
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
                            }
                            
                            Spacer(minLength: 40)
                            
                            // MARK: - 구매하기 버튼
                            Button {
                                Task {
                                    guard let wallet = appState.connectedAddress else {
                                        vm.errorMessage = "지갑 주소를 불러올 수 없습니다."
                                        return
                                    }
                                    await vm.purchaseTicket(walletAddress: wallet)
                                }
                            } label: {
                                Text("구매하기")
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, minHeight: 54)
                                    .background(Color.dketBlue)
                                    .cornerRadius(27)
                            }
                            .padding(.bottom, 40)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                    } else if let error = vm.errorMessage {
                        CustomAlertView(message: error) {
                            dismiss()
                        }
                    } else {
                        Text("티켓 정보를 불러올 수 없습니다.")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
            }
            
            .fullScreenCover(isPresented: $showMyPage) {
                MypageView()
            }
        }
        .task {
            await vm.reserveTicket()
        }
        .onChange(of: vm.didPurchase) { success in
            if success {
                dismiss() // 🎉 구매 성공 시 닫기
            }
        }
        .onDisappear {
            Task.detached {
                await vm.cancelReservation()
            }
        }
    }
}

// MARK: - InfoTextRow
private struct InfoTextRow: View {
    let label: String
    let value: String
    var valueColor: Color = .black
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .foregroundColor(.gray)
                .font(.system(size: 14))
                .frame(width: 80, alignment: .leading)
            Text(value)
                .font(.system(size: 14))
                .foregroundColor(valueColor)
            Spacer()
        }
    }
}

// MARK: - 구매 규정
private struct RuleText: View {
    let text: String
    init(_ text: String) { self.text = text }
    
    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Text("•")
                .foregroundColor(.gray)
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(.gray)
            Spacer()
        }
    }
}

// MARK: - Custom Alert
struct CustomAlertView: View {
    let message: String
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            // 배경 반투명 오버레이
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // 상단 닫기 버튼
                HStack {
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.gray)
                            .padding(8)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 4)
                }
                
                Image("DketEmpty")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 55, height: 75)
                    .padding(.top, -10)
                
                Text(message)
                    .font(.system(size: 17, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)
                
                Button(action: onDismiss) {
                    Text("돌아가기")
                        .font(.system(size: 16, weight: .bold))
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(Color.dketBlue)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
            .padding(.vertical, 16)
            .frame(maxWidth: 300)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.15), radius: 10, y: 4)
        }
    }
}

// MARK: - Formatting
extension Int {
    var formattedKrw: String {
        NumberFormatter.localizedString(from: NSNumber(value: self), number: .decimal) + " 원"
    }
}

extension Int64 {
    var formattedEth: String {
        let eth = Double(self) / 1_000_000_000_000_000_000
        return String(format: "%.15f ETH", eth)
    }
}


struct CustomAlertView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray.opacity(0.1).ignoresSafeArea() 
            CustomAlertView(
                message: "이미 거래 중인 티켓입니다",
                onDismiss: { print("Alert dismissed") }
            )
        }
        .previewDisplayName("Custom Alert Preview")
    }
}
