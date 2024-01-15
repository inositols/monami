import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:monami/src/features/image_upload/notifier/image_notifier.dart';
import 'package:monami/src/features/image_upload/typedef/is_loading.dart';

final imageUploaderProvider =
    StateNotifierProvider<ImageUploadNotifier, IsLoading>(
  (ref) => ImageUploadNotifier(),
);
