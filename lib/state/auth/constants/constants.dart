import 'package:flutter/foundation.dart' show immutable;

@immutable
class AuthConstants {
  static const accountExistWithdifferentCredentials =
      "account-exists-with-different-credential";

  static const emailScope = "email";
  static const googleCom = "google.com";

  const AuthConstants._();
}
