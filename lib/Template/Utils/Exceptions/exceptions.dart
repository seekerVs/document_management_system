class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

class UserNotFoundException extends AppException {
  const UserNotFoundException()
    : super('No account found with this email address.');
}

class WrongPasswordException extends AppException {
  const WrongPasswordException()
    : super('Incorrect password. Please try again.');
}

class EmailAlreadyInUseException extends AppException {
  const EmailAlreadyInUseException()
    : super('This email is already registered. Try signing in instead.');
}

class WeakPasswordException extends AppException {
  const WeakPasswordException()
    : super('Password must be at least 6 characters.');
}

class SessionExpiredException extends AppException {
  const SessionExpiredException()
    : super('Your session has expired. Please sign in again.');
}

class TooManyRequestsException extends AppException {
  const TooManyRequestsException()
    : super('Too many attempts. Please wait a moment and try again.');
}

class AccountDisabledException extends AppException {
  const AccountDisabledException()
    : super('This account has been disabled. Please contact support.');
}

class OtpNotFoundException extends AppException {
  const OtpNotFoundException()
    : super('No reset code found for this email. Please request a new one.');
}

class OtpExpiredException extends AppException {
  const OtpExpiredException()
    : super('This code has expired. Please request a new one.');
}

class OtpAlreadyUsedException extends AppException {
  const OtpAlreadyUsedException() : super('This code has already been used.');
}

class OtpWrongCodeException extends AppException {
  const OtpWrongCodeException() : super('Incorrect code. Please try again.');
}

class DocumentNotFoundException extends AppException {
  const DocumentNotFoundException()
    : super('The requested document could not be found.');
}

class FolderNotFoundException extends AppException {
  const FolderNotFoundException()
    : super('The requested folder could not be found.');
}

class PermissionDeniedException extends AppException {
  const PermissionDeniedException()
    : super('You do not have permission to perform this action.');
}

class AlreadyExistsException extends AppException {
  const AlreadyExistsException() : super('This item already exists.');
}

class DataSyncException extends AppException {
  const DataSyncException()
    : super('Data sync failed. Please pull to refresh.');
}

class NetworkException extends AppException {
  const NetworkException()
    : super('No internet connection. Please check your network.');
}

class ServerException extends AppException {
  const ServerException() : super('Server error. Please try again later.');
}

class RequestTimeoutException extends AppException {
  const RequestTimeoutException()
    : super('Request timed out. Please try again.');
}

class ApiException extends AppException {
  const ApiException(super.message);
}

class FileTooLargeException extends AppException {
  const FileTooLargeException({double maxMB = 20})
    : super('File size exceeds the ${maxMB}MB limit.');
}

class FileTypeNotSupportedException extends AppException {
  const FileTypeNotSupportedException()
    : super('File type not supported. Please upload a PDF or image.');
}

class FileUploadException extends AppException {
  const FileUploadException() : super('File upload failed. Please try again.');
}

class FileNotFoundException extends AppException {
  const FileNotFoundException() : super('The file could not be found.');
}

class TokenExpiredException extends AppException {
  const TokenExpiredException()
    : super('This signing link has expired. Please request a new one.');
}

class TokenAlreadyUsedException extends AppException {
  const TokenAlreadyUsedException()
    : super('This signing link has already been used.');
}

class TokenInvalidException extends AppException {
  const TokenInvalidException() : super('This signing link is invalid.');
}

class SignatureRequestNotFoundException extends AppException {
  const SignatureRequestNotFoundException()
    : super('Signature request could not be found.');
}

class SignatureAlreadyCompletedException extends AppException {
  const SignatureAlreadyCompletedException()
    : super('This document has already been signed.');
}



AppException authExceptionFromCode(String code) {
  switch (code) {
    case 'user-not-found':
      return const UserNotFoundException();
    case 'wrong-password':
    case 'invalid-credential':
      return const WrongPasswordException();
    case 'email-already-in-use':
      return const EmailAlreadyInUseException();
    case 'weak-password':
      return const WeakPasswordException();
    case 'too-many-requests':
      return const TooManyRequestsException();
    case 'user-disabled':
      return const AccountDisabledException();
    case 'network-request-failed':
      return const NetworkException();
    case 'operation-not-allowed':
      return const PermissionDeniedException();
    default:
      return AppException('Something went wrong. Please try again. ($code)');
  }
}

AppException firestoreExceptionFromCode(String code) {
  switch (code) {
    case 'permission-denied':
      return const PermissionDeniedException();
    case 'not-found':
      return const DocumentNotFoundException();
    case 'already-exists':
      return const AlreadyExistsException();
    case 'unavailable':
    case 'network-request-failed':
      return const NetworkException();
    case 'deadline-exceeded':
      return const RequestTimeoutException();
    case 'cancelled':
      return const DataSyncException();
    default:
      return AppException('Database error. Please try again. ($code)');
  }
}

AppException otpExceptionFromResult(String result) {
  switch (result) {
    case 'not_found':
      return const OtpNotFoundException();
    case 'expired':
      return const OtpExpiredException();
    case 'already_used':
      return const OtpAlreadyUsedException();
    case 'wrong_code':
      return const OtpWrongCodeException();
    default:
      return const AppException('Verification failed. Please try again.');
  }
}
