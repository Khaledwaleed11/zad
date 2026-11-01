import 'package:flutter/material.dart';

import '../../domain/entities/azkar_entity.dart';

class AzkarFormDialog extends StatefulWidget {
  final AzkarEntity? zekr;

  const AzkarFormDialog({super.key, this.zekr});

  @override
  State<AzkarFormDialog> createState() => _AzkarFormDialogState();
}

class _AzkarFormDialogState extends State<AzkarFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _textController;
  late final TextEditingController _countController;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.zekr?.title ?? '');

    _textController = TextEditingController(text: widget.zekr?.text ?? '');

    _countController = TextEditingController(
      text: widget.zekr?.count.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    _countController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.zekr == null ? 'إضافة ذكر جديد' : 'تعديل الذكر',
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(
                  labelText: 'عنوان الذكر',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'اكتب عنوان الذكر';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _textController,
                textDirection: TextDirection.rtl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'نص الذكر',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'اكتب نص الذكر';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _countController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'عدد التكرار',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final count = int.tryParse(value ?? '');

                  if (count == null || count <= 0) {
                    return 'أدخل عددًا صحيحًا أكبر من صفر';
                  }

                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(widget.zekr == null ? 'إضافة' : 'حفظ'),
        ),
      ],
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pop(
      context,
      AzkarEntity(
        id: widget.zekr?.id ?? 0,
        category: 'custom',
        title: _titleController.text.trim(),
        text: _textController.text.trim(),
        count: int.parse(_countController.text.trim()),
        isCustom: true,
      ),
    );
  }
}
