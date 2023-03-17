import 'package:flutter/foundation.dart' show immutable;

@immutable
class FirebaseFieldName {
  static const userId = "uid";
  static const postId = "post_id";
  static const comment = "comment";
  static const followers = "followers";
  static const following = "following";
  static const friend = "friends";
  static const chat = "chat";
  static const creatAt = "created_at";
  static const date = "date";
  static const displayName = "display_name";
  static const email = "email";
  static const phoneNumber = "phoneNumber";
  static const role = "role";

  const FirebaseFieldName._();
}
