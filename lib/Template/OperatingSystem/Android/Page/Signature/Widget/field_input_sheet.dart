import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Commons/Styles/style.dart';
import '../../../../../Commons/Widgets/app_button.dart';
import '../../../../../Commons/Widgets/app_text_field.dart';
import '../../../../../Utils/Constant/enum.dart';
import '../../../../../Utils/Formatters/formatter.dart';
import '../Model/signature_field_model.dart';

class FieldInputSheet extends StatefulWidget {
  final SignatureFieldModel field;
  final void Function(String value) onConfirm;

  const FieldInputSheet({
    super.key,
    required this.field,
    required this.onConfirm,
  });

  // Show appropriate sheet based on field type
  static void show({
    required SignatureFieldModel field,
    required void Function(String value) onConfirm,
    required String signerName,
  }) {
    // Date signed — auto-fill, no input needed
    if (field.type == SignatureFieldType.dateSigned) {
      onConfirm(AppFormatter.dateShort(DateTime.now()));
      return;
    }

    Get.bottomSheet(
      FieldInputSheet(field: field, onConfirm: onConfirm),
      isScrollControlled: true,
    );
  }

  @override
  State<FieldInputSheet> createState() => _FieldInputSheetState();
}

class _FieldInputSheetState extends State<FieldInputSheet> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  String get _title {
    switch (widget.field.type) {
      case SignatureFieldType.textbox:
        return 'Enter Text';
      default:
        return '';
    }
  }

  void _confirm() {
    final value = _textController.text.trim();
    if (value.isEmpty) return;
    Get.back();
    widget.onConfirm(value);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: AppStyle.bottomSheetHandle,
              ),
            ),
            const SizedBox(height: 20),
            Text(_title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            AppTextField(
              hint: 'Enter text here',
              controller: _textController,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _confirm(),
            ),
            const SizedBox(height: 16),
            AppButton.primary(label: 'Confirm', onPressed: _confirm),
          ],
        ),
      ),
    );
  }
}
