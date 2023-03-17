import 'package:flutter/foundation.dart' show immutable;

@immutable
class FirebaseCollectionName {
  static const thumbnail = "thumbnail";
  static const comments = "comments";
  static const followers = "followers";
  static const following = "following";
  static const chats = "chats";
  static const friends = "friends";
  static const likes = "likes";
  static const posts = "posts";
  static const users = "users";

  const FirebaseCollectionName._();
}
