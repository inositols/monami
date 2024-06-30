import 'package:flutter/foundation.dart' show immutable;

import 'package:monami/src/presentation/views/dialogs/alert_dialog_model.dart';
import 'package:monami/src/utils/constants/app_string.dart';

@immutable
class LogoutDialog extends AlertDialogModel<bool> {
  const LogoutDialog()
      : super(
            title: Strings.logOut,
            message: Strings.areYouSureThatYouWantToLogOutOfTheApp,
            buttons: const {
              Strings.cancel: false,
              Strings.logOut: true,
            });
}
