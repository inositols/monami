import 'dart:collection';

import 'package:flutter/foundation.dart' show immutable;
import 'package:monami/state/constants/firebase_field_name.dart';
import 'package:monami/state/user_info/typedefs/user_id.dart';

@immutable
class UserInfoPayload extends MapView<String, String> {
  UserInfoPayload({
    required UserId userId,
    required String? displayName,
    required String? email,
    required String? phoneNumber,
    required String role,
  }) : super(
          {
            FirebaseFieldName.userId: userId,
            FirebaseFieldName.displayName: displayName ?? '',
            FirebaseFieldName.email: email ?? '',
            FirebaseFieldName.phoneNumber: phoneNumber ?? '',
            FirebaseFieldName.role: role,
          },
        );
}
