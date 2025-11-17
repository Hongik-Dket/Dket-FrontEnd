import SwiftUI

struct ConcertDetailView: View {
    private let concertId: Int64
    @Environment(\.dismiss) private var dismiss

    // MARK: 상태 변수
    @State private var showScanner = false
    @State private var showTicketNumberEntry = false
    @State private var showTicketDetail = false
    @State private var showInvalidTicket = false
    @State private var showProgressAlert = false

    @StateObject private var vm: ConcertDetailViewModel

    @MainActor
    init(concertId: Int64) {
        self.concertId = concertId
        _vm = StateObject(wrappedValue: ConcertDetailViewModel(concertId: concertId))
    }
    
    var body: some View {
        ZStack {
            bodyView
            
            if showProgressAlert {
                ProofProgressAlertView(
                    title: "티켓 검증 인증을 진행 중입니다.",
                    message: "완료까지 약 1분 정도 소요됩니다."
                )
            }
        }
        // ✅ 상태 변화 감지 (검증중 / 성공 / 실패)
        .onChange(of: vm.verificationState) { handleVerificationStateChange($0) }
        
        // ✅ QR 스캐너
        .fullScreenCover(isPresented: $showScanner) {
            QRScannerContainerView(
                onScan: { code in
                    showScanner = false
                    vm.verifyTicket(with: code)
                },
                onManualTap: {
                    showScanner = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showTicketNumberEntry = true
                    }
                }
            )
        }
        
        // ✅ 티켓 결과 (국내/외국인 분기)
        .fullScreenCover(isPresented: $showTicketDetail) {
            if let ticket = vm.verifiedTicket {
                if vm.identityType == "PASSPORT" {
                    OrganizerOfflineVerifyView(ticketId: ticket.ticketId) {
                        showTicketDetail = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            showScanner = true
                        }
                    }
                } else {
                    OrganizerTicketVerifiedView(showScanner: $showScanner) // ✅ 바인딩 연결
                }
            }
        }
        
        // ✅ QR 수동입력
        .fullScreenCover(isPresented: $showTicketNumberEntry) {
            OrganizerTicketNumberCheckView {
                showTicketNumberEntry = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showScanner = true
                }
            }
        }

        // ✅ 검증 실패 (QR 이상)
        .fullScreenCover(isPresented: $showInvalidTicket) {
            InvalidTicketView()
        }
    }

    // MARK: - 검증 상태 변경 처리
    private func handleVerificationStateChange(_ state: ConcertDetailViewModel.VerificationState) {
        switch state {
        case .verifying:
            showProgressAlert = true
        case .success:
            showProgressAlert = false
            showTicketDetail = true
        case .failure:
            showProgressAlert = false
            showInvalidTicket = true
        default:
            break
        }
    }

    // MARK: - 본문
    @ViewBuilder
    private var bodyView: some View {
        switch vm.state {
        case .idle, .loading:
            ProgressView().task { vm.onAppear() }
        case .failed(let error):
            VStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 32))
                    .foregroundStyle(.orange)
                Text(error.localizedDescription)
                Button("다시 시도") { vm.onAppear() }
            }
        case .loaded:
            if let detail = vm.detail {
                content(detail)
            }
        }
    }

    // MARK: - 공연 상세 본문
    @ViewBuilder
    func content(_ d: ConcertDetail) -> some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // 포스터
                    HStack {
                        Spacer()
                        PosterView(url: d.poster, status: d.status)
                        Spacer()
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        BasicInfoView(detail: d, showResaleInfo: true)
                        Divider()

                        if d.status == .applyNotOpened {
                            Text("응모 D-\(Date().daysUntil(d.applyPeriod.lowerBound))일")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Divider()
                        } else {
                            SessionPickerView(detail: d)
                            Divider()
                            SessionStatSection()
                        }

                        if !d.photoCards.isEmpty {
                            photoCardSection(d.photoCards)
                        }
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 80)
                }
                .padding(.vertical, 12)
            }
            .refreshable { await vm.refresh() }

            if d.status == .inProgress {
                FloatingEnterButton()
            }
        }
        .environmentObject(vm)
    }

    // MARK: - 입장 버튼
    @ViewBuilder
    private func FloatingEnterButton() -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: { showScanner = true }) {
                    Label("공연 입장 확인하기", systemImage: "ticket.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: 360, maxHeight: 48)
                        .background(isTodaySession ? Color.dketBlue : Color.gray.opacity(0.5))
                        .cornerRadius(24)
                        .shadow(radius: 4)
                }
                .disabled(!isTodaySession)
            }
            .padding()
        }
    }

    private var isTodaySession: Bool {
        guard let s = vm.selectedSession else { return false }
        let today = Calendar.current.startOfDay(for: Date())
        let sessionDay = Calendar.current.startOfDay(for: s.date)
        return today == sessionDay
    }

    // MARK: - 포토카드 섹션
    @ViewBuilder
    private func photoCardSection(_ photoCards: [PhotoCardInfo]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("포토카드")
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(photoCards, id: \.id) { photo in
                        AsyncImage(url: URL(string: photo.imageUrl)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 80, height: 100)
                            case .success(let img):
                                img
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 100)
                                    .clipped()
                                    .cornerRadius(8)
                            case .failure:
                                Color.gray.opacity(0.2)
                                    .overlay(Image(systemName: "photo"))
                                    .frame(width: 80, height: 100)
                                    .cornerRadius(8)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
private struct SessionStatSection: View {
    @EnvironmentObject private var vm: ConcertDetailViewModel
    
    var body: some View {
        if let detail = vm.detail, let s = vm.selectedSession {
            VStack(alignment: .leading, spacing: 15) {
                Text(s.date.formatted(.dateTime.year().month().day()))
                    .font(.title3).bold()
                
                Group {
                    let (title, count): (String, Int) = {
                        switch detail.status {
                        case .applyOpen:
                            return ("응모자 수", s.applyCount)
                        case .applyClosed, .ticketed:
                            return ("예매자 수", s.paidCount ?? 0)
                        case .inProgress:
                            return ("입장 완료 수", s.attendeeCount ?? 0)
                        case .ended:
                            return ("관람자 수", s.attendeeCount ?? 0)
                        default:
                            return ("", 0)
                        }
                    }()
                    
                    HStack {
                        Text(title)
                            .font(.caption)
                        Spacer()
                        Text("\(count)명")
                    }
                    
                    if detail.status != .applyNotOpened && detail.status != .ended {
                        let percent = detail.capacity > 0
                        ? Double(count) / Double(detail.capacity)
                        : 0
                        HStack {
                            Text({
                                switch detail.status {
                                case .applyOpen:
                                    return "응모 달성률"
                                case .inProgress:
                                    return "입장 달성률"
                                default:
                                    return "예매 달성률"
                                }
                            }())
                            .font(.caption)
                            
                            Spacer()
                            Text("\(Int(percent * 100))%")
                                .bold()
                                .font(.caption)
                        }
                        ProgressView(value: percent)
                            .progressViewStyle(.linear)
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
    
    private struct StatText: View {
        let title: String
        let value: Int
        var body: some View {
            HStack {
                Text(title).font(.caption)
                Spacer()
                Text("\(value)").bold()
            }
        }
    }
}
