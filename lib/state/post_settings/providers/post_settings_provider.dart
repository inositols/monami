import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:monami/state/post_settings/models/post_settings.dart';
import 'package:monami/state/post_settings/notifier/post_setting_notifer.dart';

final postSettingProvider =
    StateNotifierProvider<PostSettingNotifier, Map<PostSetting, bool>>(
  (ref) => PostSettingNotifier(),
);
