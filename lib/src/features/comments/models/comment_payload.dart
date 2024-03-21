import 'dart:collection' show MapView;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:monami/src/data/state/constants/firebase_field_name.dart';
import 'package:monami/src/data/state/post/typedefs/post_id.dart';
import 'package:monami/src/data/state/user_info/typedefs/user_id.dart';

@immutable
class CommentPayload extends MapView<String, dynamic> {
  CommentPayload({
    required UserId fromUserId,
    required PostId onPostId,
    required String review,
  }) : super({
          FirebaseFieldName.userId: fromUserId,
          FirebaseFieldName.postId: onPostId,
          FirebaseFieldName.review: review,
          FirebaseFieldName.creatAt: FieldValue.serverTimestamp(),
        });
}
