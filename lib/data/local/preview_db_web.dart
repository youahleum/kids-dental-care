import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:sqlite3/wasm.dart';

/// 웹 미리보기용 임시 DB: 워커 없이 페이지 안에서 메모리로만 돈다.
///
/// 기본 웹 DB는 공유 워커(SharedWorker)를 쓰는데, 워커의 네트워크 요청이 막힌
/// 환경(일부 내장 브라우저 미리보기)에서는 열리지 않는다. 그런 환경에서
/// `--dart-define=MEMDB=true`로 화면만 확인할 때 쓴다. 새로고침하면 데이터는 사라진다.
Future<QueryExecutor?> openPreviewExecutor() async {
  final sqlite3 = await WasmSqlite3.loadFromUrl(Uri.parse('sqlite3.wasm'));
  sqlite3.registerVirtualFileSystem(InMemoryFileSystem(), makeDefault: true);
  return WasmDatabase.inMemory(sqlite3);
}
