import '../../domain/models/preventive_task.dart';

/// 표준 예방치료/검진 일정 시드 항목.
/// [offsetMonths]는 생년월일 기준 개월 오프셋.
/// 기준 문서: PLAN.md 3장 (국가 영유아 구강검진 4회 + 예방치료 권고)
class SeedTask {
  const SeedTask({
    required this.type,
    required this.title,
    required this.offsetMonths,
  });

  final PreventiveType type;
  final String title;
  final int offsetMonths;
}

/// 표준 일정. 실제 시기는 아이마다 다르므로 "권고 안내"이며
/// 최종 판단은 치과 상담임을 UI에 고지한다(DisclaimerBanner).
const scheduleSeed = <SeedTask>[
  SeedTask(
    type: PreventiveType.firstVisit,
    title: '첫 치과 방문',
    offsetMonths: 12, // 첫 유치 맹출 무렵
  ),
  SeedTask(
    type: PreventiveType.checkup,
    title: '국가 구강검진 1차 (만 2세)',
    offsetMonths: 18,
  ),
  SeedTask(
    type: PreventiveType.checkup,
    title: '국가 구강검진 2차 (만 3세)',
    offsetMonths: 30,
  ),
  SeedTask(
    type: PreventiveType.fluoride,
    title: '불소도포',
    offsetMonths: 30, // 유치 어금니 맹출 후, 검진과 함께
  ),
  SeedTask(
    type: PreventiveType.checkup,
    title: '국가 구강검진 3차 (만 4세)',
    offsetMonths: 42,
  ),
  SeedTask(
    type: PreventiveType.checkup,
    title: '국가 구강검진 4차 (만 5세)',
    offsetMonths: 54,
  ),
  SeedTask(
    type: PreventiveType.sealant,
    title: '실란트 (6세 어금니)',
    offsetMonths: 72, // 첫 영구 어금니 맹출 직후
  ),
  SeedTask(
    type: PreventiveType.sealant,
    title: '실란트 (12세 어금니)',
    offsetMonths: 144, // 제2대구치 맹출 직후
  ),
];
