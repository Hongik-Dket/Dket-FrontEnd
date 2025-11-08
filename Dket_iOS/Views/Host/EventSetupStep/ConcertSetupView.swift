//
//  FirstStepView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/25/25.
//

import SwiftUI

struct ConcertSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var step: Step = .one
    @StateObject private var viewModel = ConcertSetupViewModel()
    
    // STEP 1
    @State private var title = ""
    @State private var ageFilter: String?
    @State private var location = ""
    @State private var description = ""
    @State private var isResaleAllowed: Bool = false
    
    // STEP 2
    @State private var performanceStart = Date()
    @State private var performanceEnd   = Date()
    @State private var startTime        = Date()
    @State private var endTime          = Date()
    @State private var price            = "" //
    @State private var capacity         = ""
    @State private var enrollStartDate  = Date()
    @State private var enrollStartTime  = Date()
    @State private var enrollEndDate    = Date()
    @State private var enrollEndTime    = Date()
    
    // STEP 3
    @State private var bannerImage: UIImage?
    @State private var posterImage: UIImage?
    @State private var photocardImages: [UIImage] = []
    
    // MARK: – 최종 모달 플로우
    @State private var showModal = false
    @State private var modalStep = 1
    @State private var showNotice = false
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    @EnvironmentObject private var appState: AppState
    @State private var showMypage = false
    
    enum Step { case one, two, three }
    
    var body: some View {
        VStack(spacing: 0) {
            BackHeaderView(
                onBack: { dismiss() },
                onMenu: { showMypage = true }
            )
            
            StepIndicatorView(current: step)
                .padding(.vertical, 8)
            Divider()
            
            Group {
                switch step {
                case .one:
                    FirstStepView(
                        title: $title,
                        ageFilter: $ageFilter,
                        location: $location,
                        description: $description,
                        isResaleAllowed: $isResaleAllowed
                    )
                case .two:
                    SecondStepView(
                        performanceStart: $performanceStart,
                        performanceEnd:   $performanceEnd,
                        startTime:        $startTime,
                        endTime:          $endTime,
                        priceKrw:         $price,
                        capacity:         $capacity,
                        enrollStartDate:  $enrollStartDate,
                        enrollStartTime:  $enrollStartTime,
                        enrollEndDate:    $enrollEndDate,
                        enrollEndTime:    $enrollEndTime
                    )
                case .three:
                    ThirdStepView(
                        bannerImage: $bannerImage,
                        posterImage: $posterImage,
                        photocardImages: $photocardImages
                    )
                }
            }
            .padding()
            .animation(.easeInOut, value: step)
            
            Spacer()
            
            if showNotice {
                Text("🎉 공연이 성공적으로 등록되었습니다!")
                    .font(.system(size: 16, weight: .medium))
                    .padding()
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            HStack(spacing: 12) {
                if step != .one {
                    Button("이전으로") { back() }
                        .buttonStyle(PrimaryButtonStyle(filled: true))
                        .font(.system(size: 16, weight: .bold))
                }
                Button(step == .three ? "개최하기" : "다음으로") { next() }
                    .buttonStyle(PrimaryButtonStyle(filled: isNextEnabled))
                    .disabled(!isNextEnabled)
            }
            .padding(.horizontal)
            .padding(.bottom, 70)
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarHidden(true)
        .sheet(isPresented: $showModal) {
            PopupFlowView(
                step: $modalStep,
                isPresented: $showModal,
                onComplete: {
                    withAnimation { showNotice = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        dismiss()
                    }
                },
                viewModel: viewModel
            )
        }
        .onReceive(viewModel.$state) { state in
            if case .loaded = state {
                modalStep = 1
                showModal = true
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("입력 오류"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
        }
        .fullScreenCover(isPresented: $showMypage) {
            MypageView().environmentObject(appState)
        }
    }
    
    // MARK: - Step 이동
    private func next() {
        switch step {
        case .one:
            step = .two
            
        case .two:
            let calendar = Calendar(identifier: .gregorian)
            guard
                let finalApplyStart = calendar.date(
                    bySettingHour: calendar.component(.hour, from: enrollStartTime),
                    minute: calendar.component(.minute, from: enrollStartTime),
                    second: 0,
                    of: enrollStartDate
                ),
                let finalApplyEnd = calendar.date(
                    bySettingHour: calendar.component(.hour, from: enrollEndTime),
                    minute: calendar.component(.minute, from: enrollEndTime),
                    second: 0,
                    of: enrollEndDate
                )
            else {
                alertMessage = "응모 시작/종료 시간이 올바르지 않습니다."
                showingAlert = true
                return
            }
            
            if finalApplyEnd <= finalApplyStart {
                alertMessage = "응모 마감일은 시작일보다 이후여야 합니다."
                showingAlert = true
                return
            }
            
            if calendar.date(byAdding: .day, value: 2, to: finalApplyEnd)! > calendar.startOfDay(for: performanceStart) {
                alertMessage = "응모 마감 후 최소 2일 후에 공연이 시작되어야 합니다."
                showingAlert = true
                return
            }
            
            if performanceEnd < performanceStart {
                alertMessage = "공연 종료일은 공연 시작일보다 이후여야 합니다."
                showingAlert = true
                return
            }
            step = .three
            
        case .three:
            let calendar = Calendar(identifier: .gregorian)
            
            guard
                let finalApplyStart = calendar.date(
                    bySettingHour: calendar.component(.hour, from: enrollStartTime),
                    minute: calendar.component(.minute, from: enrollStartTime),
                    second: 0,
                    of: enrollStartDate
                ),
                let finalApplyEnd = calendar.date(
                    bySettingHour: calendar.component(.hour, from: enrollEndTime),
                    minute: calendar.component(.minute, from: enrollEndTime),
                    second: 0,
                    of: enrollEndDate
                )
            else {
                print("⛔️ 응모 시작/종료 시간 결합 실패")
                return
            }
            
            viewModel.title = title
            viewModel.location = location
            viewModel.description = description
            viewModel.startDate = performanceStart
            viewModel.endDate = performanceEnd
            viewModel.startTimeText = DateFormatter.HHmm.string(from: startTime)
            viewModel.endTimeText = DateFormatter.HHmm.string(from: endTime)
            viewModel.price = Int(price) ?? 0 
            viewModel.capacity = Int(capacity) ?? 0
            viewModel.applyStart = finalApplyStart
            viewModel.applyEnd = finalApplyEnd
            viewModel.ageLimit = AgeLimit(rawValue: ageFilter ?? "ALL") ?? .all
            viewModel.isResaleAllowed = isResaleAllowed
            viewModel.bannerImageData = bannerImage?.jpegData(compressionQuality: 0.8)
            viewModel.posterImageData = posterImage?.jpegData(compressionQuality: 0.8)
            viewModel.photocardImageDatas = photocardImages.compactMap {
                $0.jpegData(compressionQuality: 0.4)
            }
            
            modalStep = 1
            showModal = true
        }
    }
    
    private func back() {
        switch step {
        case .one: break
        case .two: step = .one
        case .three: step = .two
        }
    }
    
    private var isNextEnabled: Bool {
        switch step {
        case .one:
            return !title.isEmpty &&
            ageFilter != nil &&
            !location.isEmpty &&
            !description.isEmpty
        case .two:
            return performanceStart <= performanceEnd &&
            startTime <= endTime &&
            !price.isEmpty &&
            !capacity.isEmpty
        case .three:
            return bannerImage != nil && posterImage != nil
        }
    }
}

