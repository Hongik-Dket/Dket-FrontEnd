//
//  BuyerEventDetailView.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/6/25.
//

import SwiftUI


struct BuyerConcertDetailView: View {
    let concertId: Int64
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var vm: BuyerConcertViewModel
    
    @State private var showApplySuccessAlert = false
    
    @State private var showTicketDetail = false
    @State private var selectedTicketId: Int64?
    
    init(concertId: Int64) {
        self.concertId = concertId
        _vm = StateObject(wrappedValue: BuyerConcertViewModel(concertId: concertId))
    }
    
    var body: some View {
        Group {
            switch vm.state {
            case .idle, .loading:
                ProgressView().task { await vm.fetch() }
            case .failed(let error):
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 32))
                        .foregroundStyle(.orange)
                    Text(error.localizedDescription)
                    Button("다시 시도") { Task { await vm.fetch() } }
                }
            case .loaded:
                if let detail = vm.detail {
                    content(detail)
                }
            }
        }
        .navigationTitle("공연 상세")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
        }
        .onAppear {
            Task {
                await vm.fetch()
                await MainActor.run {
                    vm.updateFloatingButton(for: vm.selectedSession)
                }
            }
        }
        
    }
    
    @ViewBuilder
    func content(_ detail: ConcertDetail) -> some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Spacer()
                        PosterView(url: detail.poster, status: detail.status)
                        Spacer()
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        BasicInfoView(detail: detail)
                        Divider()
                        
                        if detail.status == .applyNotOpened {
                            Text("응모 D-\(Date().daysUntil(detail.applyPeriod.lowerBound))일")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        } else {
                            BuyerSessionPickerView(detail: detail)
                                .environmentObject(vm)
                            Divider()
                            BuyerSessionStatSection()
                                .environmentObject(vm)
                            
                            if vm.isResaleButtonVisible {
                                HStack {
                                    Button(action: {
                                        if let url = URL(string: "https://resale.dket.io/concert/\(concertId)") {
                                            UIApplication.shared.open(url)
                                        }
                                    }) {
                                        Text("리세일 마켓으로 가기 →")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.dketBlue)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(Color.dketBlue, lineWidth: 1)
                                            )
                                    }
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 80)
                }
                .padding(.vertical, 12)
            }
            .refreshable { await vm.refresh() }
            
            VStack {
                Spacer()
                
                
                if vm.floatingButtonTitle != "" {
                    Button(action: {
                        Task {
                            print("[DEBUG] floatingAction = \(vm.floatingAction.rawValue)")
                            switch vm.floatingAction {
                            case .purchase, .buy:
                                await vm.preparePurchase()
                                await vm.fetch()
                                
                            case .apply:
                                let success = await vm.applyToSelectedSession()
                                if success {
                                    await MainActor.run {
                                        showApplySuccessAlert = true
                                    }
                                    await vm.fetch()
                                }
                            case .view:
                                if let ticketId = vm.selectedSession?.ticketId {
                                    print("🎯 ticketId 설정됨: \(ticketId)")
                                    DispatchQueue.main.async {
                                        self.selectedTicketId = ticketId
                                        self.showTicketDetail = true
                                    }
                                } else {
                                    print("❌ 선택된 세션에 ticketId가 없음")
                                }
                            case .enter:
                                if let ticketId = vm.selectedSession?.ticketId {
                                    print("🎫 공연 입장: ticketId = \(ticketId)")
                                    DispatchQueue.main.async {
                                        self.selectedTicketId = ticketId
                                        self.showTicketDetail = true
                                    }
                                } else {
                                    print("❌ 공연 입장 실패: ticketId 없음")
                                }
                                
                            default:
                                print("[DEBUG] default case triggered")
                                break
                            }
                        }
                    }) {
                        Text(vm.floatingButtonTitle)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, maxHeight: 48)
                            .background(vm.isFloatingButtonEnabled ? Color.dketBlue : Color.gray)
                            .cornerRadius(24)
                            .shadow(radius: 4)
                            .padding(.horizontal)
                    }
                    .disabled(!vm.isFloatingButtonEnabled)
                    .padding(.bottom)
                }
            }
            .fullScreenCover(item: $selectedTicketId) { ticketId in
                BuyerTicketDetailView(ticketId: ticketId)
            }
        }
        .overlay {
            ZStack {
                if showApplySuccessAlert {
                    ApplySuccessModalView {
                        showApplySuccessAlert = false
                    }
                }
                
                if vm.showBuyConfirmAlert {
                    BuyConfirmAlertView(
                        priceEth: vm.ticketPriceEthString,
                        onConfirm: {
                            Task {
                                await vm.confirmPurchase()
                                await MainActor.run {
                                    vm.updateFloatingButton(for: vm.selectedSession)
                                }
                            }
                        },
                        onCancel: {
                            vm.showBuyConfirmAlert = false
                        }
                    )
                }
            }
        }
    }
}

private struct BuyerSessionStatSection: View {
    @EnvironmentObject private var vm: BuyerConcertViewModel
    
    var body: some View {
        if let concert = vm.detail, let session = vm.selectedSession {
            VStack(alignment: .leading, spacing: 15) {
                Text(session.date.formatted(.dateTime.year().month().day()))
                    .font(.title3).bold()
                
                HStack {
                    Text("잔여 티켓")
                        .font(.caption)
                    Spacer()
                    Text("\(concert.capacity - session.paidCount)장")
                }
                .font(.subheadline)
                
                let label = vm.sessionApplyStatusLabel(session)
                if !label.isEmpty {
                    HStack {
                        Text("상태")
                            .font(.caption)
                        Spacer()
                        Text(label)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            ProgressView()
                .frame(maxWidth: .infinity)
        }
    }
}

extension Int64: Identifiable {
    public var id: Int64 { self }
}
