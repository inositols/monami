import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monami/src/presentation/views/profile/components/loading_view.dart';
import 'package:monami/src/presentation/views/profile/components/profile_view_model.dart';
import 'package:monami/src/presentation/views/profile/components/profile_widget.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final notifier = ref.read(userProfileProvider.notifier);
    return userProfileAsync.when(
      loading: () => const LoadingView(),
      error: (error, stack) => const ErrorView(),
      data: (userProfile) {
        if (userProfile == null) {
          return const ErrorView();
        }
        return ProfileWidget(
            userProfile: userProfile,
            ref: ref,
            loadUserProfile: notifier.loadProfile);
      },
    );
  }
}
