//
//  FirstStepView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/25/25.
//

import SwiftUI

struct EventSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var step: Step = .one
    @StateObject private var viewModel = EventSetupViewModel()
    
    // STEP 1
    @State private var title = ""
    @State private var ageFilter: String?
    @State private var location = ""
    @State private var description = ""
    
    // STEP 2
    @State private var performanceStart = Date()
    @State private var performanceEnd   = Date()
    @State private var startTime        = Date()
    @State private var endTime          = Date()
    @State private var price            = ""
    @State private var capacity         = ""
    @State private var enrollStart      = Date()
    @State private var enrollEnd        = Date()
    
    // STEP 3
    @State private var bannerImage: UIImage?
    @State private var posterImage: UIImage?
    @State private var photocardImage: UIImage?
    
    // MARK: – 최종 모달 플로우
    @State private var showModal = false
    @State private var modalStep = 1   // 1,2,3 단계를 PopupFlowView 에 전달
    @State private var showNotice = false     // 개최 완료 공지
    
    enum Step { case one, two, three }
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: A) 커스텀 백헤더
            BackHeaderView(
                onBack: { dismiss() },
                onMenu: { /* 메뉴 토글 */ }
            )
            
            // MARK: B) STEP 인디케이터
            StepIndicatorView(current: step)
                .padding(.vertical, 8)
            Divider()
            
            // MARK: C) STEP 콘텐츠
            Group {
                switch step {
                case .one: FirstStepView(
                    title: $title,
                    ageFilter: $ageFilter,
                    location: $location,
                    description: $description
                )
                case .two:
                    SecondStepView(
                        performanceStart: $performanceStart,
                        performanceEnd:   $performanceEnd,
                        startTime:        $startTime,
                        endTime:          $endTime,
                        price:            $price,
                        capacity:         $capacity,
                        enrollStart:      $enrollStart,
                        enrollEnd:        $enrollEnd
                    )
                case .three:
                    ThirdStepView(
                        bannerImage: $bannerImage,
                        posterImage: $posterImage,
                        photocardImage: $photocardImage
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
            
            // MARK: D) 하단 이전/다음 버튼
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
        
        // 뷰모델 상태 변화를 관찰해서 모달 띄우기
        .onReceive(viewModel.$state) { state in
            if case .loaded = state {
                modalStep = 1
                showModal = true
            }
        }
    }
    
    private func next() {
        switch step {
        case .one:   step = .two
        case .two:   step = .three
        case .three: // 로컬 @State → 뷰모델로 복사
            viewModel.title          = title
            viewModel.location       = location
            viewModel.description    = description
            viewModel.startDate      = performanceStart
            viewModel.endDate        = performanceEnd
            viewModel.startTimeText  = DateFormatter.HHmm.string(from: startTime)
            viewModel.endTimeText    = DateFormatter.HHmm.string(from: endTime)
            viewModel.price          = Int(price) ?? 0
            viewModel.capacity       = Int(capacity) ?? 0
            viewModel.applyStart     = enrollStart
            viewModel.applyEnd       = enrollEnd
            viewModel.bannerImageData    = bannerImage?.jpegData(compressionQuality: 0.8)
            viewModel.posterImageData    = posterImage?.jpegData(compressionQuality: 0.8)
            viewModel.photocardImageData = photocardImage?.jpegData(compressionQuality: 0.8)
            
            modalStep = 1
            showModal = true
        }
    }
    private func back() {
        switch step {
        case .one:   break
        case .two:   step = .one
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
            return performanceStart <= performanceEnd
            && startTime       <= endTime
            && !price.isEmpty
            && !capacity.isEmpty
        case .three:
            return bannerImage != nil && posterImage != nil
        }
    }
}



struct EventSetupStep1View_Previews: PreviewProvider {
    static var previews: some View {
        EventSetupView()
    }
}
