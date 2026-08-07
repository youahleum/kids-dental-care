import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/age_utils.dart';
import '../../data/providers.dart';
import '../../domain/models/child.dart';
import '../../domain/services/schedule_engine.dart';

/// 자녀 등록/편집 화면. 기준: DESIGN.md 6-2
class ChildEditScreen extends ConsumerStatefulWidget {
  const ChildEditScreen({super.key, this.existing});

  /// null이면 신규 등록, 있으면 편집.
  final Child? existing;

  @override
  ConsumerState<ChildEditScreen> createState() => _ChildEditScreenState();
}

class _ChildEditScreenState extends ConsumerState<ChildEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  DateTime? _birthDate;
  late int _colorValue;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameController = TextEditingController(text: e?.name ?? '');
    _birthDate = e?.birthDate;
    _colorValue = e?.colorValue ?? AppColors.childPalette.first.toARGB32();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? now,
      firstDate: DateTime(now.year - 18),
      lastDate: now,
      helpText: '생년월일 선택',
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('생년월일을 선택해 주세요.')));
      return;
    }
    final repo = ref.read(childRepositoryProvider);
    final name = _nameController.text.trim();
    if (_isEdit) {
      await repo.update(widget.existing!.copyWith(
        name: name,
        birthDate: _birthDate,
        colorValue: _colorValue,
      ));
    } else {
      final childId = await repo.add(
        name: name,
        birthDate: _birthDate!,
        colorValue: _colorValue,
      );
      // 생일 기준 예방치료·검진 타임라인 자동 생성 (PLAN.md 7장)
      final tasks = ScheduleEngine.generate(_birthDate!);
      await ref
          .read(preventiveTaskRepositoryProvider)
          .createForChild(childId, tasks);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = _birthDate == null
        ? '생년월일 선택'
        : DateFormat('yyyy-MM-dd').format(_birthDate!);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? '자녀 편집' : '자녀 추가'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('저장', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '이름',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? '이름을 입력해 주세요.' : null,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: '생년월일',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(dateLabel),
                    if (_birthDate != null)
                      Text(
                        AgeUtils.label(_birthDate!),
                        style: TextStyle(color: Theme.of(context).hintColor),
                      ),
                    const Icon(Icons.calendar_today, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('프로필 색상'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final c in AppColors.childPalette)
                  GestureDetector(
                    onTap: () => setState(() => _colorValue = c.toARGB32()),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _colorValue == c.toARGB32()
                              ? AppColors.mintDark
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: _colorValue == c.toARGB32()
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              '저장하면 생일 기준으로 예방치료·검진 타임라인이 자동 생성됩니다.',
              style: TextStyle(color: Theme.of(context).hintColor, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _save,
              child: Text(_isEdit ? '저장' : '자녀 추가하기'),
            ),
          ],
        ),
      ),
    );
  }
}
