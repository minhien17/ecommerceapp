import 'package:ecommerce/common/widgets/flutter_toast.dart';
import 'package:ecommerce/exceptions/firebaseauth/messaged_firebase.dart';
import 'package:ecommerce/services/database/user_database_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../exceptions/firebaseauth/credential_actions_exceptions.dart';
import '../../exceptions/firebaseauth/reauth_exceptions.dart';

class AuthentificationService {
  static const String USER_NOT_FOUND_EXCEPTION_CODE = "user-not-found";
  static const String WRONG_PASSWORD_EXCEPTION_CODE = "wrong-password";
  static const String TOO_MANY_REQUESTS_EXCEPTION_CODE = 'too-many-requests';
  static const String EMAIL_ALREADY_IN_USE_EXCEPTION_CODE =
      "email-already-in-use";
  static const String OPERATION_NOT_ALLOWED_EXCEPTION_CODE =
      "operation-not-allowed";
  static const String WEAK_PASSWORD_EXCEPTION_CODE = "weak-password";
  static const String USER_MISMATCH_EXCEPTION_CODE = "user-mismatch";
  static const String INVALID_CREDENTIALS_EXCEPTION_CODE = "invalid-credential";
  static const String INVALID_EMAIL_EXCEPTION_CODE = "invalid-email";
  static const String USER_DISABLED_EXCEPTION_CODE = "user-disabled";
  static const String INVALID_VERIFICATION_CODE_EXCEPTION_CODE =
      "invalid-verification-code";
  static const String INVALID_VERIFICATION_ID_EXCEPTION_CODE =
      "invalid-verification-id";
  static const String REQUIRES_RECENT_LOGIN_EXCEPTION_CODE =
      "requires-recent-login";

  FirebaseAuth _firebaseAuth;

  AuthentificationService._privateConstructor()
      : _firebaseAuth = FirebaseAuth.instance;
  static AuthentificationService _instance =
      AuthentificationService._privateConstructor();

  FirebaseAuth get firebaseAuth {
    if (_firebaseAuth == null) {
      _firebaseAuth = FirebaseAuth.instance;
    }
    return _firebaseAuth;
  }

  factory AuthentificationService() {
    return _instance;
  }

  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  Stream<User?> get userChanges => firebaseAuth.userChanges();

  Future<void> deleteUserAccount() async {
    await currentUser.delete();
    await signOut();
  }

  // Future<bool> reauthCurrentUser(password) async {
  //   try {
  //     UserCredential userCredential =
  //         await firebaseAuth.signInWithEmailAndPassword(
  //             email: currentUser.email, password: password);
  //     userCredential = await currentUser
  //         .reauthenticateWithCredential(userCredential.credential);
  //   } on FirebaseAuthException catch (e) {
  //     if (e.code == WRONG_PASSWORD_EXCEPTION_CODE) {
  //       throw FirebaseSignInAuthWrongPasswordException();
  //     } else {
  //       throw FirebaseSignInAuthException(message: e.code);
  //     }
  //   } catch (e) {
  //     throw FirebaseReauthUnknownReasonFailureException(message: e.toString());
  //   }
  //   return true;
  // }

  void signIn(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      if (credential.user == null) {
        null;
      }
      if (!credential.user!.emailVerified) {}
      var user = credential.user;

      if (user != null) {
        // đăng ký thành công nó thay đổi trạng thái stream --> Thay đổi điều kiện trong wrapper
      } else {}
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        toastInfo(msg: 'user-not-found');
      } else if (e.code == "invalid-credential") {
        toastInfo(msg: 'Invalid credential');
      } else if (e.code == 'too-many-requests') {
        toastInfo(msg: 'too-many-requests');
      }
    }
  }

  void signUp(
      {required String email,
      required String password,
      Function()? callback}) async {
    try {
      final UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      final String uid = userCredential.user!.uid;
      if (userCredential.user!.emailVerified == false) {
        await userCredential.user!.sendEmailVerification();
      }
      await UserDatabaseHelper().createNewUser(uid);
      callback!();
    } on FirebaseAuthException catch (e) {
      if (e.code == EMAIL_ALREADY_IN_USE_EXCEPTION_CODE) {
        toastInfo(msg: 'email-already-in-use');
      } else if (e.code == INVALID_EMAIL_EXCEPTION_CODE) {
        toastInfo(msg: 'invalid-email');
      } else if (e.code == OPERATION_NOT_ALLOWED_EXCEPTION_CODE) {
        toastInfo(msg: 'operation-not-allowed');
      } else if (e.code == WEAK_PASSWORD_EXCEPTION_CODE) {
        toastInfo(msg: 'weak-password');
      } else {
        toastInfo(msg: e.code);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  bool get currentUserVerified {
    currentUser.reload();
    return currentUser.emailVerified;
  }

  Future<void> sendVerificationEmailToCurrentUser() async {
    await firebaseAuth.currentUser!.sendEmailVerification();
  }

  User get currentUser {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in.');
    }
    return user;
  }

  Future<void> updateCurrentUserDisplayName(String updatedDisplayName) async {
    await currentUser.updateProfile(displayName: updatedDisplayName);
  }

  // Future<bool> resetPasswordForEmail(String email) async {
  //   try {
  //     await firebaseAuth.sendPasswordResetEmail(email: email);
  //     return true;
  //   } on MessagedFirebaseAuthException {
  //     rethrow;
  //   } on FirebaseAuthException catch (e) {
  //     if (e.code == USER_NOT_FOUND_EXCEPTION_CODE) {
  //       throw FirebaseCredentialActionAuthUserNotFoundException();
  //     } else {
  //       throw FirebaseCredentialActionAuthException(message: e.code);
  //     }
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  Future<bool> changePasswordForCurrentUser(
      {String? oldPassword, required String newPassword}) async {
    try {
      bool isOldPasswordProvidedCorrect = true;
      if (oldPassword != null) {
        isOldPasswordProvidedCorrect =
            await verifyCurrentUserPassword(oldPassword);
      }
      if (isOldPasswordProvidedCorrect) {
        await firebaseAuth.currentUser?.updatePassword(newPassword);

        return true;
      } else {
        throw FirebaseReauthWrongPasswordException();
      }
    } on MessagedFirebaseAuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case WEAK_PASSWORD_EXCEPTION_CODE:
          throw FirebaseCredentialActionAuthWeakPasswordException();
        case REQUIRES_RECENT_LOGIN_EXCEPTION_CODE:
          throw FirebaseCredentialActionAuthRequiresRecentLoginException();
        default:
          throw FirebaseCredentialActionAuthException(message: e.code);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> changeEmailForCurrentUser(
      {String? password, String? newEmail}) async {
    try {
      bool isPasswordProvidedCorrect = true;
      if (password != null) {
        isPasswordProvidedCorrect = await verifyCurrentUserPassword(password);
      }
      if (isPasswordProvidedCorrect) {
        await currentUser.verifyBeforeUpdateEmail(newEmail ?? '');

        return true;
      } else {
        throw FirebaseReauthWrongPasswordException();
      }
    } on MessagedFirebaseAuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw FirebaseCredentialActionAuthException(message: e.code);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> verifyCurrentUserPassword(String password) async {
    try {
      final AuthCredential authCredential = EmailAuthProvider.credential(
        email: currentUser.email ?? '',
        password: password,
      );

      final authCredentials =
          await currentUser.reauthenticateWithCredential(authCredential);
      return authCredentials != null;
    } on MessagedFirebaseAuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case USER_MISMATCH_EXCEPTION_CODE:
          toastInfo(msg: USER_MISMATCH_EXCEPTION_CODE);
          throw FirebaseReauthUserMismatchException();
        case USER_NOT_FOUND_EXCEPTION_CODE:
          toastInfo(msg: USER_NOT_FOUND_EXCEPTION_CODE);
          throw FirebaseReauthUserNotFoundException();
        case INVALID_CREDENTIALS_EXCEPTION_CODE:
          toastInfo(msg: INVALID_CREDENTIALS_EXCEPTION_CODE);
          throw FirebaseReauthInvalidCredentialException();
        case INVALID_EMAIL_EXCEPTION_CODE:
          toastInfo(msg: INVALID_EMAIL_EXCEPTION_CODE);
          throw FirebaseReauthInvalidEmailException();
        case WRONG_PASSWORD_EXCEPTION_CODE:
          toastInfo(msg: WRONG_PASSWORD_EXCEPTION_CODE);
          throw FirebaseReauthWrongPasswordException();
        case INVALID_VERIFICATION_CODE_EXCEPTION_CODE:
          toastInfo(msg: INVALID_VERIFICATION_CODE_EXCEPTION_CODE);
          throw FirebaseReauthInvalidVerificationCodeException();
        case INVALID_VERIFICATION_ID_EXCEPTION_CODE:
          toastInfo(msg: INVALID_VERIFICATION_ID_EXCEPTION_CODE);
          throw FirebaseReauthInvalidVerificationIdException();
        default:
          toastInfo(msg: e.code);
          throw FirebaseReauthException(message: e.code);
      }
    } catch (e) {
      rethrow;
    }
  }
}
