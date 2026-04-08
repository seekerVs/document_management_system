import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dashed_rect_painter.dart';

class UploadSignatureTab extends StatelessWidget {
  final Function(Uint8List) onImageSelected;

  const UploadSignatureTab({super.key, required this.onImageSelected});

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      onImageSelected(bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(top: 24),
      width: double.infinity,
      child: CustomPaint(
        painter: DashedRectPainter(
          color: colorScheme.outline,
          strokeWidth: 2,
          gap: 5,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _pickImage,
              child: const Text('UPLOAD YOUR SIGNATURE'),
            ),
            const SizedBox(height: 8),
            Text(
              'PNG, JPG or JPEG',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
