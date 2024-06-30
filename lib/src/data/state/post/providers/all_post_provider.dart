import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:monami/src/data/state/constants/firebase_collection.dart';
import 'package:monami/src/data/state/constants/firebase_field_name.dart';
import 'package:monami/src/data/state/post/models/post.dart';

final allPostsProvider = StreamProvider.autoDispose<Iterable<Post>>(
  (ref) {
    final controller = StreamController<Iterable<Post>>();

    final sub = FirebaseFirestore.instance
        .collection(
          FirebaseCollectionName.products,
        )
        .orderBy(
          FirebaseFieldName.creatAt,
          descending: true,
        )
        .snapshots()
        .listen(
      (snapshots) {
        final posts = snapshots.docs.map(
          (doc) => Post(
            json: doc.data(),
            postId: doc.id,
          ),
        );
        controller.sink.add(posts);
      },
    );

    ref.onDispose(() {
      sub.cancel();
      controller.close();
    });

    return controller.stream;
  },
);
