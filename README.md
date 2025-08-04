# 소린이의 주변 장소 검색 및 리뷰 앱 (Nearby Finder)

이 프로젝트는 Flutter와 Riverpod를 사용하여 개발된 주변 장소 검색 및 리뷰 애플리케이션입니다. 사용자는 키워드를 통해 원하는 장소를 검색하거나, 현재 위치 기반으로 주변 장소를 탐색할 수 있습니다. 또한, 각 장소에 대한 리뷰를 확인하고 직접 작성할 수 있습니다.

-----

## 주요 기능

### 장소 검색 (키워드 & 현재 위치)

장소를 찾는 방법은 두 가지입니다. 사용자가 직접 키워드를 입력하거나, GPS를 통해 현재 위치를 기반으로 검색할 수 있습니다.

#### 1\. 키워드로 검색

  * **작동 방식**: 메인 화면의 검색창에 찾고 싶은 장소의 이름(예: '강남역', '스타필드')을 입력하고 검색 버튼을 누릅니다.
  * **핵심 기술**: 입력된 키워드는 **Naver 지역 검색 API**로 전송되어 장소 목록(이름, 주소, 좌표 등)을 반환받아 화면에 표시합니다.
  * **사용자 경험**: 검색 중에는 로딩 아이콘을, 결과가 없을 때는 '검색 결과가 없습니다'라는 명확한 피드백을 제공합니다.

#### 2\. 현재 위치로 검색

  * **작동 방식**: 앱 상단의 GPS 아이콘(⌖)을 누르면, 사용자의 현재 위치를 파악해 주변 장소를 자동으로 검색합니다.
  * **핵심 기술 (다단계 프로세스)**:
    1.  **권한 확인 및 좌표 획득**: `geolocator` 패키지로 사용자의 GPS 활성화 여부와 권한을 확인한 뒤, 현재 위도/경도 좌표를 얻습니다.
    2.  **좌표 → 주소 변환**: 숫자 좌표를 사람이 읽을 수 있는 주소로 변환합니다. `geocoding` 패키지를 우선 사용하고, 실패 시 대한민국 내 좌표일 경우 **V-World API**를 통해 정확도를 높여 재시도합니다.
    3.  **주변 장소 검색**: 변환된 주소를 키워드로 사용하여 **Naver 지역 검색 API**에 최종적으로 주변 장소 목록을 요청합니다.

### 리뷰 기능

검색한 장소를 선택하면, 해당 장소에 대한 다른 사람들의 리뷰를 보고 자신의 리뷰를 남길 수 있습니다.

  * **작동 방식**: 장소 목록에서 특정 항목을 탭하면 리뷰 화면으로 이동합니다. 이곳에서 리뷰 목록을 확인하고, 하단의 입력창을 통해 새 리뷰를 작성할 수 있습니다.
  * **핵심 기술**:
      * **데이터베이스**: 모든 리뷰 데이터는 **Firebase Firestore**에 저장됩니다.
      * **고유 ID 관리**: 각 장소의 좌표값(`mapx`, `mapy`)을 조합하여 고유 ID를 생성하고, 이를 통해 장소별 리뷰를 정확하게 구분하여 관리합니다.
      * **자동 업데이트**: 새 리뷰를 등록하면 `flutter_riverpod`의 `ref.invalidateSelf()`가 호출되어, 별도의 새로고침 없이도 화면의 리뷰 목록이 **자동으로 갱신**됩니다.

-----

## 기술 스택 및 주요 라이브러리

  * **Framework**: Flutter
  * **State Management**: `flutter_riverpod`
  * **Backend & Database**: Firebase (Firestore)
  * **API & Networking**: `dio`
  * **Location Services**: `geolocator`, `geocoding`
  * **Asynchronous Programming**: Future, Async/Await
  * **UI**: Material Design
  * **etc**: `intl`

-----

## 프로젝트 구조

```
lib
├── main.dart                 # 앱 시작점, Firebase 초기화
|
├── data
│   ├── model                 # 데이터 모델 (Location, Review)
│   └── repository            # 데이터 소스(API, DB)와 통신하는 레포지토리
|
├── screens
│   ├── location_search_screen.dart # 메인 화면 (장소 검색)
│   └── review_screen.dart      # 리뷰 목록 및 작성 화면
|
└── viewmodels
    ├── location_viewmodel.dart   # 장소 검색 관련 비즈니스 로직
    └── review_viewmodel.dart     # 리뷰 관련 비즈니스 로직
```

-----

## 작동법 및 테스트 가이드

### 기본 작동법

1.  **키워드 검색**: 메인 화면 검색창에 키워드를 입력하고 검색합니다.
2.  **현재 위치 검색**: 메인 화면 우측 상단의 GPS 아이콘을 탭합니다. (위치 권한 허용 필요)
3.  **리뷰 확인 및 작성**: 검색 결과 목록에서 장소를 탭하여 리뷰 화면으로 이동한 후, 리뷰를 확인하거나 작성합니다.

### iOS 시뮬레이터 위치 설정 가이드

개발 환경에서 특정 위치의 검색 결과를 테스트해야 할 경우, 아래 방법으로 시뮬레이터의 위치를 직접 설정할 수 있습니다.

1.  Xcode를 통해 iOS 시뮬레이터를 실행합니다.
2.  시뮬레이터의 상단 메뉴 바에서 **Features → Location → Custom Location...** 을 선택합니다.
3.  나타나는 팝업 창에 원하는 위치의 \*\*위도(Latitude)\*\*와 \*\*경도(Longitude)\*\*를 입력합니다. (예: 서울 시청 - 위도: `37.5665`, 경도: `126.9780`)
4.  설정이 완료되면, 앱에서 '현재 위치로 검색' 기능을 실행했을 때 시뮬레이터에 설정된 위치를 기준으로 주변 장소를 검색합니다.

-----

## 빌드 및 개발 가이드

### iOS 빌드 시 주의사항

이 프로젝트는 Firebase 및 여러 네이티브 라이브러리를 사용하기 때문에, Xcode에서 **concurrent builds** 오류가 발생할 수 있습니다. 이는 코드의 문제가 아닌 Xcode의 시스템적 제약사항입니다.

#### 해결 방법

1. **권장: 빌드 스크립트 사용**
   ```bash
   ./build_ios.sh debug    # 디버그 빌드
   ./build_ios.sh release  # 릴리즈 빌드
   ```

2. **수동 빌드 시**
   ```bash
   # 환경변수 설정 후 빌드
   export RUN_CLANG_STATIC_ANALYZER=0 && \
   export DISABLE_MANUAL_TARGET_ORDER_BUILD_WARNING=YES && \
   flutter build ios --debug --no-codesign
   ```

3. **문제 지속 시**
   ```bash
   # 완전 클린 후 재빌드
   flutter clean
   rm -rf ios/Pods ios/Podfile.lock
   flutter pub get
   cd ios && pod install
   ```

### 적용된 최적화

- **Podfile**: 병렬 빌드 비활성화, Firebase/gRPC 관련 최적화 설정
- **Xcode Scheme**: `parallelizeBuildables = "NO"` 설정
- **빌드 스크립트**: 자동화된 클린업 및 환경변수 설정