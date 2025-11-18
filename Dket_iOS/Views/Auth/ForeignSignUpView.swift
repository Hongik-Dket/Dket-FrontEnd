//
//  ForeignSignUpView.swift
//  Dket_iOS
//
//  Created by M-136 on 11/3/25.
//

import SwiftUI

struct ForeignSignUpView: View {
    @State private var passportNumber: String = ""
    @State private var gender: String? = nil
    @State private var englishLastName: String = ""
    @State private var englishFirstName: String = ""
    @State private var birthDate: Date = Date()
    @State private var nationality: String = ""
    @State private var passportExpiryDate: Date = Date()
    
    @State private var showBirthPicker = false
    @State private var showExpiryPicker = false
    @State private var isLoading = false
    @State private var goToMetaMask = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // ✅ 전세계 국가 목록 생성 (ISO 코드 기반)
    private var allCountries: [String] {
        Locale.isoRegionCodes
            .compactMap { Locale.current.localizedString(forRegionCode: $0) } // 코드 → 이름 변환
            .filter { !$0.localizedCaseInsensitiveContains("Korea") } // 한국 제거
            .sorted(by: { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }) // 알파벳순 정렬
    }

    var isFormComplete: Bool {
        !passportNumber.isEmpty &&
        gender != nil &&
        !englishLastName.isEmpty &&
        !englishFirstName.isEmpty &&
        !nationality.isEmpty
    }
    
    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    // MARK: - 로고
                    HStack {
                        Spacer()
                        Image("Dket")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 40.38)
                            .padding(.top, 10)
                        Spacer()
                    }
                    
                    Group {
                        // MARK: - 여권번호
                        Text("여권 번호")
                            .font(.system(size: 14, weight: .bold))
                        TextField("여권 번호를 입력하세요", text: $passportNumber)
                            .textFieldStyle(.roundedBorder)
                        
                        // MARK: - 성별
                        Text("성별")
                            .font(.system(size: 14, weight: .bold))
                        HStack(spacing: 12) {
                            GenderButton(title: "남성", isSelected: gender == "남성") { gender = "남성" }
                            GenderButton(title: "여성", isSelected: gender == "여성") { gender = "여성" }
                        }
                        
                        // MARK: - 영문 이름
                        Text("영문 성")
                            .font(.system(size: 14, weight: .bold))
                        TextField("예: YEO", text: $englishLastName)
                            .textFieldStyle(.roundedBorder)
                        
                        Text("영문 이름")
                            .font(.system(size: 14, weight: .bold))
                        TextField("예: HEEJU", text: $englishFirstName)
                            .textFieldStyle(.roundedBorder)
                        
                        // MARK: - 생년월일
                        Text("생년월일")
                            .font(.system(size: 14, weight: .bold))
                        
                        Button {
                            withAnimation { showBirthPicker.toggle() }
                        } label: {
                            dateField(title: dateFormatter.string(from: birthDate), isExpanded: showBirthPicker)
                        }
                        
                        if showBirthPicker {
                            DatePicker("", selection: $birthDate, displayedComponents: .date)
                                .datePickerStyle(.wheel)
                                .labelsHidden()
                                .transition(.opacity.combined(with: .slide))
                        }
                        
                        // MARK: - 국적
                        Text("국적")
                            .font(.system(size: 14, weight: .bold))
                        Picker("국가 선택", selection: $nationality) {
                            Text("국가 선택").tag("")
                            ForEach(allCountries, id: \.self) { country in
                                Text(country).tag(country)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(.black)
                        
                        // MARK: - 여권 만료일
                        Text("여권 만료일")
                            .font(.system(size: 14, weight: .bold))
                        Button {
                            withAnimation { showExpiryPicker.toggle() }
                        } label: {
                            dateField(title: dateFormatter.string(from: passportExpiryDate), isExpanded: showExpiryPicker)
                        }
                        
                        if showExpiryPicker {
                            DatePicker("", selection: $passportExpiryDate, displayedComponents: .date)
                                .datePickerStyle(.wheel)
                                .labelsHidden()
                                .transition(.opacity.combined(with: .slide))
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer(minLength: 40)
                    
                    // MARK: - 시작하기 버튼
                    Button {
                        Task { await handleSignUp() }
                    } label: {
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity, minHeight: 48)
                        } else {
                            Text("시작하기")
                                .font(.system(size: 16, weight: .bold))
                                .frame(maxWidth: .infinity, minHeight: 48)
                        }
                    }
                    .background(isFormComplete ? Color(red: 22/255, green: 29/255, blue: 111/255) : Color.gray.opacity(0.4))
                    .foregroundColor(.white)
                    .cornerRadius(6)
                    .padding(.horizontal, 30)
                    .disabled(!isFormComplete || isLoading)
                    .padding(.bottom, 50)
                }
                .navigationBarTitleDisplayMode(.inline)
            }
            .navigationDestination(isPresented: $goToMetaMask) {
                MetaMaskConnectView()
            }
            .alert("회원가입 실패", isPresented: $showAlert) {
                Button("확인", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    
    // MARK: - 회원가입 처리
    private func handleSignUp() async {
        guard isFormComplete, let gender = gender else { return }
        isLoading = true
        defer { isLoading = false }
        
        let request = PassportSignUpRequestDTO(
            passportNumber: passportNumber,
            gender: gender == "남성" ? .male : .female,
            firstName: englishFirstName,
            lastName: englishLastName,
            birthDate: dateFormatter.string(from: birthDate),
            nationality: nationality,
            passportExpiry: dateFormatter.string(from: passportExpiryDate)
        )
        
        do {
            let response = try await SignUpService.shared.signUpForeign(request)
            if response.isSuccess, let token = response.result?.token {
                print("회원가입 성공. 토큰: \(token)")
                TokenManager.saveToken(token)
                goToMetaMask = true
            } else {
                alertMessage = response.message
                showAlert = true
            }
        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
        }
    }
    
    // MARK: - Date Field
    private func dateField(title: String, isExpanded: Bool) -> some View {
        HStack {
            Text(title).foregroundColor(.black)
            Spacer()
            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                .foregroundColor(.gray)
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}


// MARK: - 성별 선택 버튼
struct GenderButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .frame(width: 80, height: 36)
                .background(isSelected ? Color(red: 22/255, green: 29/255, blue: 111/255) : Color.gray.opacity(0.15))
                .foregroundColor(isSelected ? .white : .black)
                .cornerRadius(5)
        }
    }
}

// MARK: - Preview
#Preview {
    ForeignSignUpView()
        .previewDisplayName("🌍 Foreign Sign Up (with API)")
}
