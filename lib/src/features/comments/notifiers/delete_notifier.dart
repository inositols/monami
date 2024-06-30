import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:monami/src/features/comments/typedef/comment_typedef.dart';
import 'package:monami/src/data/state/constants/firebase_collection.dart';
import 'package:monami/src/features/image_upload/typedef/is_loading.dart';

class DeleCommentStateNotifier extends StateNotifier<IsLoading> {
  DeleCommentStateNotifier() : super(false);

  set isLoading(bool value) => state = value;

  Future<bool> deleteComment({
    required CommentId commentId,
  }) async {
    try {
      isLoading = true;
      final query = FirebaseFirestore.instance
          .collection(
            FirebaseCollectionName.reviews,
          )
          .where(
            FieldPath.documentId,
            isEqualTo: commentId,
          )
          .limit(1)
          .get();

      await query.then(
        (query) async {
          for (final doc in query.docs) {
            await doc.reference.delete();
          }
        },
      );

      return true;
    } catch (e) {
      return false;
    } finally {
      isLoading = false;
    }
  }
}
