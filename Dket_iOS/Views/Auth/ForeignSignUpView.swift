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
    
    let countries = ["United States", "Canada", "United Kingdom", "Australia", "Japan", "Korea", "Germany", "France", "China", "Singapore"]
    
    var isFormComplete: Bool {
        !passportNumber.isEmpty &&
        gender != nil &&
        !englishLastName.isEmpty &&
        !englishFirstName.isEmpty &&
        !nationality.isEmpty
    }
    
    // MARK: - Date Formatters
    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "yyyy.MM.dd"
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
                        TextField("예: KIM", text: $englishLastName)
                            .textFieldStyle(.roundedBorder)
                        
                        Text("영문 이름")
                            .font(.system(size: 14, weight: .bold))
                        TextField("예: JI WOO", text: $englishFirstName)
                            .textFieldStyle(.roundedBorder)
                        
                        // MARK: - 생년월일
                        Text("생년월일")
                            .font(.system(size: 14, weight: .bold))
                        
                        Button {
                            withAnimation { showBirthPicker.toggle() }
                        } label: {
                            HStack {
                                Text(dateFormatter.string(from: birthDate))
                                    .foregroundColor(.black)
                                Spacer()
                                Image(systemName: showBirthPicker ? "chevron.up" : "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
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
                            ForEach(countries, id: \.self) { country in
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
                            HStack {
                                Text(dateFormatter.string(from: passportExpiryDate))
                                    .foregroundColor(.black)
                                Spacer()
                                Image(systemName: showExpiryPicker ? "chevron.up" : "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
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
                        print("회원가입 완료 요청")
                    } label: {
                        Text("시작하기")
                            .font(.system(size: 16, weight: .bold))
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(isFormComplete ? Color(red: 22/255, green: 29/255, blue: 111/255) : Color.gray.opacity(0.4))
                            .foregroundColor(.white)
                            .cornerRadius(6)
                            .padding(.horizontal, 30)
                    }
                    .disabled(!isFormComplete)
                    .padding(.bottom, 50)
                }
                .navigationBarTitleDisplayMode(.inline)
            }
        }
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

#Preview {
    ForeignSignUpView()
        .previewDisplayName("🌍 Foreign Sign Up View - Foldable DatePicker")
}
