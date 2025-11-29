# :Dket iOS Application

**:Dket(디켓)** 의 iOS 클라이언트 애플리케이션 리포지토리입니다.
이 앱은 **구매자(Buyer)** 와 **개최자(Organizer)** 모드를 모두 지원하며, 생체 인증과 영지식 증명(ZKP)을 결합하여 안전한 티켓 예매, 관리, 입장을 제공합니다.

---

## 🛠 Tech Stack

### Platform & Language
* **iOS (Swift 5.0+)**
* **SwiftUI** (UI Framework)
* **MVVM** (Design Pattern)

### Blockchain & Security
* **WalletConnect v2**: 외부 암호화폐 지갑(MetaMask 등) 연동 및 트랜잭션 서명
* **Secure Enclave**: 기기 하드웨어 기반 키 관리 및 생체 인증(FaceID/TouchID)
* **Web3.swift**: 이더리움 네트워크 상호작용 및 서명 처리

### Networking
* **Alamofire**: RESTful API 통신

---

## 📂 Project Structure

```bash
Dket_iOS
├── App
│   └── Dket_iOSApp.swift       # 앱 엔트리 포인트
├── Views                       # SwiftUI 뷰 계층
│   ├── Auth                    # 로그인, 지갑 연동, 사용자 유형별(내국인/외국인) 가입 UI
│   ├── Buyer                   # 구매자: 홈, 예매, 마이티켓, 스크린샷 방지 뷰
│   └── Host                    # 주최자: 공연 등록, QR 스캔, 입장 검증
├── Services                    # 네트워킹 및 외부 서비스 연동
│   ├── WalletConnect           # 지갑 연결 관리자
│   ├── ProofService            # 입장 증명(QR) 요청 서비스
│   └── BiometricManager        # 생체 인증 및 서명 생성 (Secure Enclave)
└── Resources                   # Assets, Colors, Info.plist
````

-----

## 🚀 Getting Started

### 1\. Prerequisites

  * **Xcode 14.0** 이상 (iOS 16.0+ Target)
  * Swift Package Manager (SPM) 의존성 동기화 필요

### 2\. Installation

```bash
git clone https://github.com/hongik-dket/dket-ios.git
open Dket_iOS.xcodeproj
```

### 3\. Build & Run

  * 시뮬레이터 또는 실제 기기(생체 인증 테스트 권장)를 선택하여 빌드합니다.

-----

## 🔑 Key Features & Logic

### 1\. Secure Wallet & Transactions

  * **WalletConnect:** MetaMask 등 외부 지갑과 연동하여 블록체인 계정을 안전하게 연결합니다. 앱 내에 개인키를 저장하지 않는 비수탁(Non-Custodial) 방식을 지향합니다.
  * **On-Chain Confirmation:** 티켓 구매, 리세일 등록(Approve), 리세일 구매 등 자산 이동이 발생하는 모든 트랜잭션은 **MetaMask 앱을 통해 사용자의 최종 서명(Confirm)** 을 받아야만 블록체인에 전송됩니다.

### 2\. Biometric Security (Device Binding)

  * **기기 고유 키 등록:** 회원가입 시, Secure Enclave에서 생성된 **공개키(Public Key)** 를 서버에 등록하여 계정을 해당 기기에 종속시킵니다.
  * **서명 기반 인증:** 결제나 입장 등 중요 행위 시 생체 인증(FaceID/TouchID)을 통해 기기의 Secure Enclave 내부에서 서명을 생성합니다. 서버는 등록된 공개키로 이 서명을 검증하므로, 단순 계정 정보 탈취만으로는 **대리 예매 및 계정 양도가 불가능**합니다.

### 3\. Privacy-Preserving Entry (Zero-Copy QR)

  * **ZKP 입장 증명:** 서버로부터 검증된 **ZKP QR 코드**를 수신하여 표시합니다. 개인정보는 노출되지 않습니다.
  * **스크린샷 방지 (Anti-Capture):** 입장 QR 화면에서는 **화면 캡처 및 녹화가 불가능**하도록 보안 뷰(`ScreenshotPreventView`)가 적용되어 있어, QR 코드 무단 복제를 방지합니다.

### 4\. Secure Resale Process

  * **시스템 인증 거래:** 앱에서 리세일 구매 요청 시, 먼저 백엔드에 요청하여 유효성 검증 서명을 받아옵니다. 이 서명을 포함하여 트랜잭션을 전송함으로써, 사용자는 **Race Condition**이나 불법 거래 걱정 없이 안전하게 티켓을 구매할 수 있습니다.

### 5\. Organizer Mode (Host Features)

  * **공연 관리:** 주최자는 앱 내에서 직접 공연 정보를 입력하고 회차를 등록(`ConcertSetupView`)할 수 있습니다.
  * **QR 검증:** 입장 게이트에서 관객의 QR 코드를 스캔하여, 블록체인 상의 유효성을 실시간으로 검증(`QRScanView`)하고 입장을 처리합니다.

-----

## 📜 License

This project is licensed under the MIT License.
