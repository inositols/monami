import 'package:flutter/cupertino.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:monami/src/features/image_upload/models/thumbnail_request.dart';
import 'package:monami/src/features/image_upload/providers/thumbnail_provider.dart';
import 'package:monami/src/presentation/views/components/animation/models/loadin_animation.dart';
import 'package:monami/src/presentation/views/components/animation/models/small_error_animation.dart';

class FileThumbnailView extends ConsumerWidget {
  final ThumbnailRequest thumbnailRequest;
  const FileThumbnailView({super.key, required this.thumbnailRequest});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final thumbnail = ref.watch(thumbnailProvider(thumbnailRequest));
    return thumbnail.when(data: (imageWithAspectRatio) {
      return AspectRatio(
        aspectRatio: imageWithAspectRatio.aspectRatio,
        child: imageWithAspectRatio.image,
      );
    }, error: (error, stackTrace) {
      return const SmallErrorAnimationView();
    }, loading: () {
      return const LoadingAnimationView();
    });
  }
}
