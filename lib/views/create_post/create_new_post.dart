import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:monami/src/features/auth/providers/user_id_provider.dart';
import 'package:monami/src/features/image_upload/models/file_type.dart';
import 'package:monami/src/features/image_upload/models/thumbnail_request.dart';
import 'package:monami/src/features/image_upload/providers/image_uploader_provider.dart';
import 'package:monami/state/post_settings/models/post_settings.dart';
import 'package:monami/state/post_settings/providers/post_settings_provider.dart';
import 'package:monami/views/components/file_thumbnail.dart';
import 'package:monami/views/constants/strings.dart';
import 'package:monami/views/onboarding/components/constants/app_color.dart';

class CreateNewPostView extends StatefulHookConsumerWidget {
  final File fileToPost;
  final FileType fileType;

  const CreateNewPostView({
    Key? key,
    required this.fileToPost,
    required this.fileType,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateNewPostViewState();
}

class _CreateNewPostViewState extends ConsumerState<CreateNewPostView> {
  String selectedItem = "Shoes";
  List<String> dropdownItems = ['Shoes', 'Dress', 'Caps', 'Clothes'];

  @override
  Widget build(BuildContext context) {
    final thumbnailRequest = ThumbnailRequest(
      file: widget.fileToPost,
      fileType: widget.fileType,
    );
    final postSettings = ref.watch(postSettingProvider);
    final postController = useTextEditingController();
    final isPostButtonEnabled = useState(false);
    useEffect(() {
      void listener() {
        isPostButtonEnabled.value = postController.text.isNotEmpty;
      }

      postController.addListener(listener);
      return () {
        postController.removeListener(listener);
      };
    }, [postController]);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          Strings.createNewPost,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: isPostButtonEnabled.value
                ? () async {
                    // get the user id first
                    final userId = ref.read(userIdProvider);
                    // print(userId!);
                    if (userId == null) {
                      return;
                    }
                    final message = postController.text;
                    final isUploaded =
                        await ref.read(imageUploaderProvider.notifier).upload(
                              file: widget.fileToPost,
                              fileType: widget.fileType,
                              message: message,
                              postSettings: postSettings,
                              userId: userId,
                              category: selectedItem,
                            );
                    if (isUploaded && mounted) {
                      Navigator.of(context).pop();
                    }
                  }
                : null,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // thumbnail
            FileThumbnailView(
              thumbnailRequest: thumbnailRequest,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: Strings.pleaseWriteYourMessageHere,
                ),
                autofocus: true,
                maxLines: null,
                controller: postController,
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Category"),
                      SizedBox(
                        height: 70,
                        child: DropdownButton<String>(
                          alignment: Alignment.center,
                          underline: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                width: 1,
                                color: AppColor.bgColor,
                              ),
                            ),
                          ),
                          isExpanded: true,
                          value: selectedItem,
                          onChanged: (newValue) {
                            setState(() {
                              selectedItem = newValue!;
                            });
                          },
                          items: dropdownItems
                              .map<DropdownMenuItem<String>>((value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(value),
                              ),
                            );
                          }).toList(),
                        ),
                      )
                    ])),
            ...PostSetting.values.map(
              (postSetting) => ListTile(
                title: Text(postSetting.title),
                subtitle: Text(postSetting.description),
                trailing: Switch(
                  value: postSettings[postSetting] ?? false,
                  onChanged: (isOn) {
                    ref.read(postSettingProvider.notifier).setSetting(
                          postSetting,
                          isOn,
                        );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
