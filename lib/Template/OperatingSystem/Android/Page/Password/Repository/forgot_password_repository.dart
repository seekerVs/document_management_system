import '../../../../../Utils/Exceptions/exceptions.dart';
import '../../../../../../Template/Utils/Api/api_service.dart';

class ForgotPasswordRepository {
  Future<void> sendOtp(String email) async {
    final result = await ApiService.post('/auth/send-otp', {
      'email': email.trim().toLowerCase(),
    });
    if (!result.success) throw AppException(result.message);
  }

  Future<void> verifyOtp(String email, String code) async {
    final result = await ApiService.post('/auth/verify-otp', {
      'email': email.trim().toLowerCase(),
      'code': code.trim(),
    });
    if (!result.success) throw AppException(result.message);
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final result = await ApiService.post('/auth/reset-password', {
      'email': email.trim().toLowerCase(),
      'code': code.trim(),
      'newPassword': newPassword,
    });
    if (!result.success) throw AppException(result.message);
  }
}
