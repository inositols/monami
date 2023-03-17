import 'package:flutter/material.dart' show immutable;

import 'dart:collection' show MapView;

import 'package:monami/state/constants/firebase_field_name.dart';
import 'package:monami/state/user_info/typedefs/user_id.dart';

@immutable
class UserInfoModel extends MapView<String, String?> {
  final UserId userId;
  final String displayName;
  final String? email;
  final String? phoneNumber;
  final String? role;
  UserInfoModel(
      {required this.userId,
      required this.displayName,
      required this.email,
      required this.phoneNumber,
      required this.role})
      : super({
          FirebaseFieldName.userId: userId,
          FirebaseFieldName.displayName: displayName,
          FirebaseFieldName.email: email,
          FirebaseFieldName.phoneNumber: phoneNumber,
          FirebaseFieldName.role: role,
        });

  UserInfoModel.fromJson(
    Map<String, dynamic> json, {
    required UserId userId,
  }) : this(
          userId: userId,
          displayName: json[FirebaseFieldName.displayName] ?? '',
          email: json[FirebaseFieldName.email],
          phoneNumber: json[FirebaseFieldName.phoneNumber] ?? "",
          role: json[FirebaseFieldName.role] ?? "",
        );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserInfoModel &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          displayName == other.displayName &&
          email == other.email &&
          phoneNumber == other.phoneNumber &&
          role == other.role;

  @override
  int get hashCode => Object.hashAll(
        [
          userId,
          displayName,
          email,
          phoneNumber,
          role,
        ],
      );
}
