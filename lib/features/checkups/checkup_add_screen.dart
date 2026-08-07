import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/providers.dart';

/// 검진 추가 화면. 기준: DESIGN.md 6-4
class CheckupAddScreen extends ConsumerStatefulWidget {
  const CheckupAddScreen({super.key, required this.childId});

  final int childId;

  @override
  ConsumerState<CheckupAddScreen> createState() => _CheckupAddScreenState();
}

class _CheckupAddScreenState extends ConsumerState<CheckupAddScreen> {
  DateTime _date = DateTime.now();
  final _clinicController = TextEditingController();
  final _memoController = TextEditingController();

  @override
  void dispose() {
    _clinicController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 18),
      lastDate: now,
      helpText: '검진일 선택',
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    await ref.read(checkupRepositoryProvider).add(
          childId: widget.childId,
          date: _date,
          clinicName: _clinicController.text.trim().isEmpty
              ? null
              : _clinicController.text.trim(),
          memo: _memoController.text.trim().isEmpty
              ? null
              : _memoController.text.trim(),
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('검진 추가'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('저장', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          InkWell(
            onTap: _pickDate,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: '검진일',
                border: OutlineInputBorder(),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(DateFormat('yyyy-MM-dd').format(_date)),
                  const Icon(Icons.calendar_today, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _clinicController,
            decoration: const InputDecoration(
              labelText: '병원명 (선택)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _memoController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: '메모 (선택)',
              hintText: '예: 불소도포 · 충치 없음',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '저장하면 다음 검진 예정일이 자동으로 계산됩니다 (기본 6개월 후).',
            style: TextStyle(color: Theme.of(context).hintColor, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _save, child: const Text('저장')),
        ],
      ),
    );
  }
}
