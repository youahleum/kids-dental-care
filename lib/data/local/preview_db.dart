// 미리보기 전용 DB 열기. 웹에서만 동작하고 그 외 플랫폼은 null을 돌려준다.
export 'preview_db_stub.dart' if (dart.library.js_interop) 'preview_db_web.dart';
