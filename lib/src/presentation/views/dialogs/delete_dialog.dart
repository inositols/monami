import 'package:flutter/foundation.dart' show immutable;

import 'package:monami/src/presentation/views/dialogs/alert_dialog_model.dart';
import 'package:monami/src/utils/constants/app_string.dart';

@immutable
class DeletedDialog extends AlertDialogModel<bool> {
  const DeletedDialog({
    required String titleOfObjectToDelete,
  }) : super(
          title: '${Strings.delete} $titleOfObjectToDelete',
          message:
              '${Strings.areYouSureYouWantToDeleteThis} $titleOfObjectToDelete',
          buttons: const {
            Strings.cancel: false,
            Strings.delete: true,
          },
        );
}
