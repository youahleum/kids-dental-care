# 키즈 덴탈 케어 (Kids Dental Care)

아이들의 치아 건강을 관리하는 Flutter 앱. 자녀의 나이에 맞춰 **예방치료·검진 시기를
자동 안내**하고, 검진 이력·치아 상태를 기록하며, 시기가 되면 알림으로 챙겨준다.

> ⚠️ 이 앱의 일정·안내는 일반적 권고이며, 개별 아동의 실제 치료 시기는
> 반드시 치과 전문의 상담으로 결정해야 합니다.

---

## 주요 기능

| 기능 | 설명 |
|---|---|
| 👶 자녀 프로필 (다중) | 형제자매 여러 명을 색상으로 구분해 관리 |
| 🗓 예방치료 타임라인 | 생일 기준으로 국가 구강검진 4회 + 불소도포·실란트 일정 자동 생성, 완료 체크 |
| 📋 검진 기록/이력 | 검진일·병원·메모 기록, 다음 검진 예정일(+6개월) 자동 계산 |
| 🦷 치아 차트 | 유치/영구치 배열에 치아별 상태(충치·치료·실란트 등) 기록 |
| 🔔 로컬 알림 | 예방치료·검진 시기 7일 전과 당일에 알림 (네이티브) |
| 💬 AI 치아 상담 | 아이의 나이·기록을 컨텍스트로 개인화 답변 (현재 Mock, Claude API 교체 가능) |

## 기술 스택

- **Flutter** 3.44 / Dart 3.12
- **Riverpod** — 상태 관리
- **Drift** (SQLite) — 로컬 영속화
- **go_router** — 라우팅
- **flutter_local_notifications** + **timezone** — 로컬 알림

## 실행

```bash
flutter pub get
flutter run
```

### 웹으로 실행 (개발 확인용)

웹은 Drift가 `web/sqlite3.wasm` + `web/drift_worker.js`를 사용한다(이미 포함됨).

```bash
flutter run -d chrome
```

### 샘플 데이터로 실행

빈 DB일 때 자녀 2명 + 타임라인 + 검진 이력을 자동으로 채운다(개발 편의, 프로덕션 미포함).

```bash
flutter run --dart-define=SEED=true
```

## 검증

```bash
flutter analyze   # 정적 분석
flutter test      # 단위·위젯 테스트
```

## 프로젝트 구조

계층 분리로 향후 클라우드 동기화 확장에 대비한다(`domain`은 Flutter/DB 비의존).

```
lib/
├── core/        # 테마, 라우터, 나이 계산 유틸
├── domain/      # 모델, 저장소 인터페이스, 순수 로직(ScheduleEngine 등)
├── data/        # Drift DB, 저장소 구현, 알림 구현, 시드
├── features/    # 화면 (home, timeline, checkups, tooth_chart, chat, settings ...)
└── shared/      # 재사용 위젯 (ChildAvatar, ChildSwitcher ...)
```

## 문서

- [PLAN.md](PLAN.md) — 개발 계획, 연령별 구강검진/예방치료 도메인 지식, 마일스톤
- [DESIGN.md](DESIGN.md) — 컬러/타이포/컴포넌트 디자인 시스템, 화면별 설계

## 라이선스 / 상태

개인 프로젝트 (개발 중). 실제 알림 수신은 iOS/Android 실기기에서 동작한다.
