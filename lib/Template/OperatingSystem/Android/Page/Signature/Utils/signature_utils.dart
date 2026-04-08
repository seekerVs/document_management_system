import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

class SignatureUtils {
  /// Trims transparent whitespace from a signature PNG image.
  static Future<Uint8List?> trimWhitespace(Uint8List bytes) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(bytes, (ui.Image img) => completer.complete(img));
    final ui.Image image = await completer.future;

    final ByteData? data = await image.toByteData();
    if (data == null) return bytes;

    final int width = image.width;
    final int height = image.height;

    int top = height;
    int left = width;
    int bottom = 0;
    int right = 0;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int alpha = data.getUint8((y * width + x) * 4 + 3);
        if (alpha > 0) {
          if (x < left) left = x;
          if (x > right) right = x;
          if (y < top) top = y;
          if (y > bottom) bottom = y;
        }
      }
    }

    // If already tight or empty
    if (left >= right || top >= bottom) return bytes;

    final int croppedWidth = right - left + 1;
    final int croppedHeight = bottom - top + 1;

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);

    canvas.drawImageRect(
      image,
      ui.Rect.fromLTRB(
        left.toDouble(),
        top.toDouble(),
        (right + 1).toDouble(),
        (bottom + 1).toDouble(),
      ),
      ui.Rect.fromLTWH(0, 0, croppedWidth.toDouble(), croppedHeight.toDouble()),
      ui.Paint(),
    );

    final ui.Picture picture = recorder.endRecording();
    final ui.Image croppedImage = await picture.toImage(
      croppedWidth,
      croppedHeight,
    );
    final ByteData? croppedData = await croppedImage.toByteData(
      format: ui.ImageByteFormat.png,
    );

    return croppedData?.buffer.asUint8List();
  }
}
