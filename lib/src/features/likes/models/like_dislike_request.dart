import 'package:flutter/foundation.dart' show immutable;
import 'package:monami/src/data/state/post/typedefs/post_id.dart';
import 'package:monami/src/data/state/post/typedefs/user_id.dart';

@immutable
class LikeDislikeRequest {
  final PostId postId;
  final UserId likedBy;
  const LikeDislikeRequest({
    required this.postId,
    required this.likedBy,
  });
}
