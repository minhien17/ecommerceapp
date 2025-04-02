import 'package:firebase_auth/firebase_auth.dart';

abstract class MessagedFirebaseAuthException extends FirebaseAuthException {
  final String _message ;
  // MessagedFirebaseAuthException(this._message);
  MessagedFirebaseAuthException(String code, String message)
      : _message = message,
        super(code: code, message: message);
  String get message => _message;
  @override
  String toString() {
    return message;
  }
}
