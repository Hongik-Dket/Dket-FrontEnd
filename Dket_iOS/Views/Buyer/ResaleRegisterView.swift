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
    @State private var keyboardHeight: CGFloat = 0
    @State private var showAlertModal = false
    @State private var showMenu = false 
    
    init(ticket: TicketDetail) {
        _vm = StateObject(wrappedValue: ResaleRegisterViewModel(ticket: ticket))
    }
    
    var ticketPrice: Int { vm.ticket.price }
    var maxPrice: Int? { vm.ticket.isEntered ? nil : Int(Double(ticketPrice) * 1.2) }
    var resalePriceInt: Int? { Int(vm.priceText) }
    
    var isPriceValid: Bool {
        guard let resale = resalePriceInt else { return false }
        if resale <= 0 { return false }  // 0원 이하 방지

        if let max = maxPrice {
            return resale <= max // 상한만 제한, 정가 이하도 허용
        } else {
            return true // 입장 후에는 가격 제한 없음
        }
    }
    
    var isAboveMaxPrice: Bool {
        guard let resale = resalePriceInt, let max = maxPrice else { return false }
        return resale > max
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
            VStack(spacing: 0) {
                BackHeaderView(
                    title: "판매",
                    useLogo: false,
                    onBack: { dismiss() },
                    onMenu: { showMenu.toggle() }
                )
                .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
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
                                
                                HStack(spacing: 8) {
                                    Text("판매가")
                                    Spacer()
                                    
                                    TextField("판매가 입력", text: $vm.priceText)
                                        .keyboardType(.numberPad)
                                        .multilineTextAlignment(.trailing)
                                        .padding(.horizontal, 10)
                                        .frame(width: 140, height: 35)
                                        .background(Color.white)
                                        .cornerRadius(6)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(isAboveMaxPrice ? Color.red : Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                        .foregroundColor(isAboveMaxPrice ? .red : .primary)
                                    
                                    Text("원")
                                }
                                .font(.subheadline)
                                
                                if isAboveMaxPrice {
                                    Text("판매가는 정가의 120%를 초과할 수 없습니다.")
                                        .font(.footnote)
                                        .foregroundColor(.red)
                                }
                                
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
                            action: { showAlertModal = true },
                            isDisabled: !isPriceValid
                        )
                        .padding(.top)
                    }
                    .padding()
                    .padding(.bottom, keyboardHeight)
                    .animation(.easeOut(duration: 0.25), value: keyboardHeight)
                }
                .gesture(
                    TapGesture().onEnded { hideKeyboard() }
                        .exclusively(before: DragGesture().onChanged { _ in hideKeyboard() })
                )
            }
            
            if vm.isLoading {
                Color.black.opacity(0.3).ignoresSafeArea()
                ProgressView("등록 중...")
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
            }
            
            if vm.isProcessingProof {
                ProofProgressAlertView(
                    title: "티켓 소유 인증 절차를 진행 중입니다.",
                    message: "완료까지 약 1분 정도 소요됩니다."
                )
                    .transition(.opacity)
                    .animation(.easeInOut, value: vm.isProcessingProof)
            }
            
            if showAlertModal {
                ResaleSuccessAlert(
                    onConfirm: {
                        Task {
                            await vm.registerResale()
                            showAlertModal = false
                        }
                    },
                    onClose: { showAlertModal = false }
                )
                .transition(.opacity)
                .animation(.easeInOut, value: showAlertModal)
            }
            
            if showMenu {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation(.easeInOut) { showMenu = false } }
                
                VStack {
                    Spacer()
                    MypageView()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(radius: 8)
                        .transition(.move(edge: .bottom))
                        .animation(.spring(), value: showMenu)
                }
                .ignoresSafeArea()
            }
        }
        .onAppear { setupKeyboardObservers() }
        .onDisappear { removeKeyboardObservers() }
    }
}

private struct TextRow: View {
    let title: String
    let value: String
    
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(title)
                .foregroundColor(.gray)
                .font(.system(size: 13))
                .frame(width: 80, alignment: .leading)
            Text(value)
                .font(.system(size: 13))
        }
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

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}

extension ResaleRegisterView {
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification,
                                               object: nil, queue: .main) { note in
            if let frame = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardHeight = frame.height - 40
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification,
                                               object: nil, queue: .main) { _ in
            keyboardHeight = 0
        }
    }
    
    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillShowNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillHideNotification,
                                                  object: nil)
    }
}
