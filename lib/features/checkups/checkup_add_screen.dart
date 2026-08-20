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
          _ClinicField(controller: _clinicController),
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

/// 병원명 입력 — 저장된 단골 치과 이름을 자동완성으로 제안한다.
class _ClinicField extends ConsumerWidget {
  const _ClinicField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clinics = ref.watch(clinicsProvider).valueOrNull ?? const [];
    final names = clinics.map((c) => c.name).toList();

    return Autocomplete<String>(
      initialValue: TextEditingValue(text: controller.text),
      optionsBuilder: (value) {
        if (value.text.isEmpty) return names;
        return names.where(
            (n) => n.toLowerCase().contains(value.text.toLowerCase()));
      },
      onSelected: (v) => controller.text = v,
      fieldViewBuilder: (context, textController, focusNode, _) {
        // Autocomplete 내부 컨트롤러 → 외부 컨트롤러 동기화
        textController.addListener(() => controller.text = textController.text);
        return TextField(
          controller: textController,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: '병원명 (선택)',
            hintText: '저장된 단골 치과에서 선택하거나 입력',
            border: OutlineInputBorder(),
          ),
        );
      },
    );
  }
}
