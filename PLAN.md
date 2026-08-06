# 키즈 덴탈 케어 (Kids Dental Care) — 개발 계획서

> 아이들의 치아 관리를 돕는 Flutter 앱. 연령별 예방치료 안내, 검진 이력 관리,
> 알림, 치아별 상태 기록을 제공한다.

작성일: 2026-08-06

---

## 1. 앱 개요

### 목적
- 부모가 자녀의 구강 건강을 **놓치지 않고** 관리하도록 돕는다.
- "몇 개월/몇 살 때 어떤 예방치료를 해야 하는지", "언제 검진했고 다음은 언제인지"를
  자동으로 안내한다.

### 대상 사용자
- 영유아~초등 저학년 자녀를 둔 부모

### 핵심 가치
1. **놓치지 않게** — 예방치료·검진 시기를 자동 계산하고 알림
2. **한눈에** — 자녀별 타임라인과 치아 상태를 시각적으로 확인
3. **가볍게** — 계정 없이 로컬에서 바로 사용 (오프라인)

---

## 2. 결정 사항 (스코프)

| 항목 | 결정 |
|---|---|
| 데이터 저장 | **로컬 우선** (SQLite/Drift). 데이터 계층을 분리해 향후 클라우드 동기화 대비 |
| 자녀 관리 | **다중 프로필** (형제자매 여러 명) |
| 계정/로그인 | 없음 (MVP). 향후 확장 대비만 |
| 플랫폼 | iOS / Android (Flutter) |

### MVP 핵심 기능 (4가지 모두 포함)
1. **예방치료 타임라인** — 월령/나이별 해야 할 예방치료 자동 안내 + 완료 체크
2. **검진 기록/이력** — 검진일 기록, 다음 검진 예정일 계산·표시
3. **알림(로컬 푸시)** — 검진·예방치료 시기 도래 시 알림
4. **치아별 상태 기록** — 유치/영구치 치아 차트에 충치·치료 상태 기록

---

## 3. 도메인 지식 — 연령별 구강 관리 기준

> 아래 데이터는 앱에 내장할 "표준 일정" 시드 데이터의 근거다.
> (국가 영유아 구강검진 기준 + 소아치과 예방치료 권고)

### 3-1. 국가 영유아 구강검진 (무료, 본인부담 없음)
생후 14일~71개월 대상. 구강검진은 총 **4회**.

| 회차 | 시기(월령) | 나이 | 주요 내용 |
|---|---|---|---|
| 1차 | 18~29개월 | 2세 | 유치열 완성기, 첫 검진, 올바른 잇솔질·치실 교육 |
| 2차 | 30~41개월 | 3세 | 정기 검진, 불소도포 |
| 3차 | 42~53개월 | 4세 | X-ray/파노라마로 숨은 충치·과잉치·결손치 확인 |
| 4차 | 54~65개월 | 5세 | **실란트 권장(첫 영구 어금니)**, 아이 직접 잇솔질 교육 |

### 3-2. 예방치료 권고 (표준 안내 일정)

| 예방치료 | 권장 시기 | 주기 | 비고 |
|---|---|---|---|
| 첫 치과 방문 | 첫 유치 맹출 시(생후 6~12개월) | 1회 | 이후 정기 검진 시작 |
| 정기 구강검진 | 만 1세 이후 | **6개월마다** | 충치 조기 발견 |
| 불소도포 | 만 1~3세부터 | **3~6개월마다** | 유치 어금니 맹출 후 |
| 실란트(치아홈메우기) | 영구치 어금니 맹출 직후 | 1회/치아 | 6세 어금니(약 6세), 12세 어금니(약 12세) |

> ⚠️ 실제 시기는 아이마다 다르므로 앱은 "권고 안내"이며 최종 판단은 치과 상담임을
> 명시(고지 문구 필요).

### 3-3. 치아 맹출 기준 (치아 차트용)
- **유치 20개**: 생후 6개월~30개월에 걸쳐 맹출
- **영구치 (첫 영구 어금니)**: 약 6세 → 실란트 대상
- **영구치 (제2대구치)**: 약 12세 → 실란트 대상

---

## 4. 기술 스택

| 영역 | 선택 | 이유 |
|---|---|---|
| 프레임워크 | Flutter 3.44 / Dart 3.12 | 크로스플랫폼 |
| 상태관리 | **Riverpod** | 테스트 용이, 확장성, 보일러플레이트 적음 |
| 로컬 DB | **Drift** (SQLite 위) | 타입 안전 쿼리, 마이그레이션, 향후 동기화 대비 |
| 로컬 알림 | `flutter_local_notifications` + `timezone` | 예약 알림 |
| 날짜/시간 | `intl` | 나이·월령 계산, 로케일 |
| 라우팅 | `go_router` | 선언적 라우팅 |
| 아이콘/UI | Material 3 | 표준 디자인 |

> 상태관리는 Riverpod을 기본 제안. 만약 더 단순함을 원하면 `provider`로 대체 가능.

---

## 5. 아키텍처 (계층 분리 — 클라우드 확장 대비)

```
lib/
├── main.dart
├── app.dart                      # MaterialApp, 라우터, 테마
│
├── core/                         # 공통
│   ├── theme/                    # 색상, 타이포
│   ├── router/                   # go_router 설정
│   └── utils/                    # 나이/월령 계산 등
│
├── domain/                       # 순수 비즈니스 (플랫폼 독립)
│   ├── models/                   # Child, Checkup, PreventiveTask, ToothRecord
│   ├── repositories/             # 추상 인터페이스 (interface만)
│   └── services/                 # 일정 계산 로직 (ScheduleEngine)
│
├── data/                         # 데이터 구현
│   ├── local/                    # Drift DB, DAO
│   ├── repositories_impl/        # 추상 repo의 로컬 구현
│   └── seed/                     # 표준 예방치료/검진 일정 시드 데이터
│
├── features/                     # 화면 단위 (UI + Riverpod provider)
│   ├── children/                 # 자녀 프로필 CRUD
│   ├── timeline/                 # 예방치료 타임라인
│   ├── checkups/                 # 검진 기록/이력
│   ├── tooth_chart/              # 치아별 상태 기록
│   └── notifications/            # 알림 설정
│
└── shared/                       # 재사용 위젯
```

**핵심 원칙**: `domain`은 Flutter/DB에 의존하지 않는다. Repository는 인터페이스로
두고 `data`에서 구현 → 나중에 `data/remote/`(Firebase 등)만 추가하면 클라우드 확장.

---

## 6. 데이터 모델 (초안)

```dart
// 자녀 프로필
Child {
  id, name, birthDate, gender?, photoPath?, createdAt
}

// 예방치료/검진 항목 (표준 템플릿 → 자녀별 인스턴스)
PreventiveTask {
  id, childId,
  type,            // checkup | fluoride | sealant | firstVisit
  title,           // "3세 국가 구강검진", "불소도포"
  recommendedDate, // 생일 기준 자동 계산
  status,          // pending | done | skipped
  completedDate?,
  note?
}

// 검진 기록 (실제 다녀온 이력)
CheckupRecord {
  id, childId, date, clinicName?, memo?,
  nextRecommendedDate  // date + 6개월(기본)
}

// 치아별 상태
ToothRecord {
  id, childId,
  toothCode,       // FDI 표기 (유치/영구치)
  status,          // healthy | caries | treated | sealant | missing
  updatedAt, note?
}
```

---

## 7. 핵심 로직 — ScheduleEngine

자녀의 `birthDate`를 입력하면 표준 시드 데이터를 기반으로 **개인화된 일정**을 생성:

```
generateTasks(child):
  for each seedTask in SEED_SCHEDULE:
    recommendedDate = birthDate + seedTask.offsetMonths
    create PreventiveTask(childId, ..., recommendedDate)

nextCheckup(child):
  lastCheckup = 가장 최근 CheckupRecord
  return lastCheckup.date + 6개월  (없으면 표준 일정 기준)
```

- 나이/월령 계산 유틸을 `core/utils`에 두고 단위 테스트로 검증.
- 시드 데이터(`data/seed/schedule_seed.dart`)는 3장 도메인 지식 기반.

---

## 8. 화면 구성 (MVP)

1. **홈 / 자녀 선택** — 등록된 자녀 카드 목록, "다음 할 일" 요약 배지
2. **자녀 등록/편집** — 이름, 생년월일, 사진
3. **타임라인** — 예방치료·검진 항목을 시간순으로, 완료 체크
4. **검진 기록** — 검진 추가(날짜/병원/메모), 이력 리스트, 다음 예정일 강조
5. **치아 차트** — 유치/영구치 배열, 탭하면 상태 기록
6. **설정** — 알림 on/off, 알림 시각, (향후) 백업

---

## 9. 개발 단계 (마일스톤)

각 단계는 **검증 기준**과 함께 진행한다.

### M1. 기반 구축
- [ ] 패키지 추가(riverpod, drift, go_router, notifications, intl)
- [ ] 폴더 구조 생성, 테마/라우터 셋업
- [ ] 검증: `flutter analyze` 통과, 빈 앱 실행

### M2. 자녀 프로필 (다중)
- [ ] Drift DB + Child 모델/DAO/Repository
- [ ] 자녀 등록/수정/삭제 UI
- [ ] 검증: 자녀 추가→재실행 후에도 유지(영속성 테스트)

### M3. 예방치료 타임라인
- [ ] 시드 일정 데이터 + ScheduleEngine
- [ ] 나이/월령 계산 유틸 + 단위 테스트
- [ ] 타임라인 UI + 완료 체크
- [ ] 검증: 생일 넣으면 올바른 시기에 항목 생성됨(테스트)

### M4. 검진 기록/이력
- [ ] CheckupRecord CRUD
- [ ] 다음 검진 예정일 계산·표시
- [ ] 검증: 검진 추가 시 다음 예정일 +6개월 계산 확인

### M5. 치아 차트
- [ ] 유치/영구치 치아 차트 위젯
- [ ] 치아별 상태 기록·표시
- [ ] 검증: 상태 저장/복원 확인

### M6. 알림
- [ ] flutter_local_notifications 초기화(iOS 권한 포함)
- [ ] 예방치료·검진 시기 도래 시 예약 알림
- [ ] 검증: 테스트 알림 예약→수신 확인

### M7. 마무리
- [ ] 고지 문구(의료 판단은 치과 상담) 삽입
- [ ] 빈 상태/에러 처리, 아이콘/스플래시
- [ ] 검증: 전체 플로우 수동 테스트

---

## 10. 향후 확장 (스코프 밖, 대비만)
- 클라우드 동기화(Firebase) — `data/remote/` 추가로 최소 변경
- 다기기/가족 공유
- 검진 사진/영수증 첨부, 치과 위치 연동
- 통계(충치 추이 등)

---

## 참고 자료 (도메인 근거)
- [영유아 건강검진 시기별 검사내용 (국민건강보험공단)](https://www.nhis.or.kr/magazin/mobile/201703/c04.html)
- [영유아 구강검진 (세종스타치과)](https://sejongstar.com/pediatric-adolescent-care/oral-examination-for-infants-and-toddlers/)
- [영유아 구강 검진 시기와 관리법 (feat. 불소 도포)](https://mom-mom.net/tips/63a171496912c1cf2efc5868)
- [소아·예방 (문치과병원)](https://moondental.co.kr/%EC%A7%84%EB%A3%8C%ED%95%AD%EB%AA%A9/%EC%86%8C%EC%95%84%EC%B9%98%EA%B3%BC/)

> ⚠️ 본 앱의 일정·안내는 일반적 권고이며, 개별 아동의 실제 치료 시기는
> 반드시 치과 전문의 상담으로 결정해야 함을 앱 내에 고지한다.
