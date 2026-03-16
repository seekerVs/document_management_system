// 📁 lib/Template/Utils/Exceptions/exceptions.dart
//
// Typed exceptions for the app.
// Throw these from repositories so controllers can show the right message.

class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

// Auth
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

// Firestore
class DocumentNotFoundException extends AppException {
  const DocumentNotFoundException()
      : super('The requested document could not be found.');
}

class PermissionDeniedException extends AppException {
  const PermissionDeniedException()
      : super('You do not have permission to perform this action.');
}

class NetworkException extends AppException {
  const NetworkException()
      : super('No internet connection. Please check your network.');
}

// Signing
class TokenExpiredException extends AppException {
  const TokenExpiredException()
      : super('This signing link has expired. Please request a new one.');
}

class TokenAlreadyUsedException extends AppException {
  const TokenAlreadyUsedException()
      : super('This signing link has already been used.');
}

class TokenInvalidException extends AppException {
  const TokenInvalidException()
      : super('This signing link is invalid.');
}

// Converts FirebaseAuthException codes to typed AppExceptions
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
    case 'network-request-failed':
      return const NetworkException();
    default:
      return AppException('Something went wrong. Please try again. ($code)');
  }
}
