import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:monami/src/features/comments/extensions/comment_sorting.dart';
import 'package:monami/src/features/comments/models/posts_comment_request.dart';
import 'package:monami/state/constants/firebase_collection.dart';
import 'package:monami/state/constants/firebase_field_name.dart';

import '../models/comments.dart';

final postCommentsProvider = StreamProvider.family
    .autoDispose<Iterable<Comment>, RequestForPostAndComments>((
  ref,
  RequestForPostAndComments request,
) {
  final controller = StreamController<Iterable<Comment>>();
  //  final sub
  FirebaseFirestore.instance
      .collection(FirebaseCollectionName.comments)
      .where(
        FirebaseFieldName.postId,
        isEqualTo: request.postId,
      )
      .snapshots()
      .listen((snapshot) {
    final documents = snapshot.docs;
    final limitedDocuments =
        request.limit != null ? documents.take(request.limit!) : documents;

    final comments = limitedDocuments
        .where(
          (doc) => !doc.metadata.hasPendingWrites,
        )
        .map(
          (document) => Comment(
            document.data(),
            id: document.id,
          ),
        );
    final result = comments.applySortingFrom(request);
    controller.sink.add(result);
  });

  ref.onDispose(() {
    controller.close();
  });

  return controller.stream;
});
