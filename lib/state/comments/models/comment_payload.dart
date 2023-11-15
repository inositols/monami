import 'dart:collection' show MapView;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:monami/state/constants/firebase_field_name.dart';
import 'package:monami/state/post/typedefs/post_id.dart';
import 'package:monami/state/user_info/typedefs/user_id.dart';

@immutable
class CommentPayload extends MapView<String, dynamic> {
  CommentPayload({
    required UserId fromUserId,
    required PostId onPostId,
    required String comment,
  }) : super({
          FirebaseFieldName.userId: fromUserId,
          FirebaseFieldName.postId: onPostId,
          FirebaseFieldName.comment: comment,
          FirebaseFieldName.creatAt: FieldValue.serverTimestamp(),
        });
}
