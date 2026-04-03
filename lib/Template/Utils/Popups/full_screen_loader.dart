import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Constant/colors.dart';

class AppLoader {
  AppLoader._();

  static bool _isShowing = false;
  static final RxString _message = ''.obs;

  static void show({String? message}) {
    if (_isShowing) return;
    _isShowing = true;
    _message.value = message ?? '';
    Get.dialog(
      const _LoaderWidget(),
      barrierDismissible: false,
      barrierColor: AppColors.overlayDark,
      useSafeArea: false,
    );
  }

  static void hide() {
    if (!_isShowing) return;
    _isShowing = false;
    _message.value = '';
    _closeDialog();
  }

  static void updateMessage(String message) => _message.value = message;

  static void _closeDialog() {
    try {
      final navigator = Get.key.currentState;
      if (navigator != null && navigator.canPop()) {
        navigator.pop();
      }
    } catch (_) {
      try {
        Get.back();
      } catch (_) {}
    }
  }
}

class _LoaderWidget extends StatelessWidget {
  const _LoaderWidget();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
          margin: const EdgeInsets.symmetric(horizontal: 48),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: AppColors.blue,
                strokeWidth: 3,
              ),
              Obx(() {
                final text = AppLoader._message.value;
                if (text.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.visible,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      decoration: TextDecoration.none,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class AppUploadLoader {
  AppUploadLoader._();

  static bool _isShowing = false;
  static final RxDouble _progress = 0.0.obs;
  static final RxString _fileName = ''.obs;

  static void show({required String fileName}) {
    if (_isShowing) return;
    _isShowing = true;
    _progress.value = 0.0;
    _fileName.value = fileName;
    Get.dialog(
      const _UploadLoaderWidget(),
      barrierDismissible: false,
      barrierColor: AppColors.overlayDark,
      useSafeArea: false,
    );
  }

  static void updateProgress(double value) =>
      _progress.value = value.clamp(0.0, 1.0);

  static void hide() {
    if (!_isShowing) return;
    _isShowing = false;
    _progress.value = 0.0;
    AppLoader._closeDialog();
  }
}

class _UploadLoaderWidget extends StatelessWidget {
  const _UploadLoaderWidget();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
          margin: const EdgeInsets.symmetric(horizontal: 48),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.upload_file_outlined,
                color: AppColors.blue,
                size: 36,
              ),
              const SizedBox(height: 12),
              const Text(
                'Uploading',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 4),
              Obx(
                () => Text(
                  AppUploadLoader._fileName.value,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: AppUploadLoader._progress.value > 0
                            ? AppUploadLoader._progress.value
                            : null,
                        backgroundColor: AppColors.grey,
                        color: AppColors.blue,
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppUploadLoader._progress.value > 0
                          ? '${(AppUploadLoader._progress.value * 100).toStringAsFixed(0)}%'
                          : 'Uploading...',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
