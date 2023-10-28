import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:monami/state/auth/providers/auth_state_provider.dart';
import 'dart:developer' as devtools show log;

import 'package:monami/state/image_upload/helpers/image_upload_helper.dart';
import 'package:monami/state/image_upload/models/file_type.dart';
import 'package:monami/state/post_settings/providers/post_settings_provider.dart';
import 'package:monami/views/create_post/create_new_post.dart';
import 'package:monami/views/dialogs/alert_dialog_model.dart';
import 'package:monami/views/dialogs/logout.dart';

extension Log on Object {
  void log() => devtools.log(toString());
}

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Monami"),
          actions: [
            IconButton(
              onPressed: () async {
                final videoFile =
                    await ImagePickerHelper.pickerVideoFromGallery();
                if (videoFile == null) {
                  return;
                }
                // ignore: unused_result
                ref.refresh(postSettingProvider);
                if (!mounted) {
                  return;
                }
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(
                    builder: (_) => CreateNewPostView(
                          fileToPost: videoFile,
                          fileType: FileType.video,
                        )));
              },
              icon: const FaIcon(FontAwesomeIcons.film),
            ),
            IconButton(
              onPressed: () async {
                final imageFile =
                    await ImagePickerHelper.pickerImageFromGallery();
                if (imageFile == null) {
                  return;
                }
                // ignore: unused_result
                ref.refresh(postSettingProvider);
                if (!mounted) {
                  return;
                }
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(
                    builder: (_) => CreateNewPostView(
                          fileToPost: imageFile,
                          fileType: FileType.image,
                        )));
              },
              icon: const Icon(Icons.add_photo_alternate_outlined),
            ),
            IconButton(
              onPressed: () async {
                final shouldLogout = await const LogoutDialog()
                    .present(context)
                    .then((value) => value ?? false);

                if (shouldLogout) {
                  await ref.read(authStateProvider.notifier).logOut();
                }
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: Container()
        // Consumer(builder: (context, ref, child) {
        //   return TextButton(
        //       onPressed: () async {
        //         // LoadingScreen.instance()
        //         //     .show(context: context, text: "Loading...");
        //         await ref.read(authStateProvider.notifier).logOut();
        //       },
        //       child: const Text('Logout'));
        // }),
        );
  }
}
