import 'package:flutter/material.dart' show immutable;

import 'dart:collection' show MapView;

import 'package:monami/src/data/state/constants/firebase_field_name.dart';
import 'package:monami/src/data/state/user_info/typedefs/user_id.dart';

@immutable
class UserInfoModel extends MapView<String, String?> {
  final UserId? userId;
  final String displayName;
  final String? email;
  final String? phoneNumber;
  final String? status;
  final String? role;
  UserInfoModel({
    required this.userId,
    required this.displayName,
    required this.email,
    required this.phoneNumber,
    required this.status,
    required this.role,
  }) : super({
          FirebaseFieldName.userId: userId,
          FirebaseFieldName.displayName: displayName,
          FirebaseFieldName.email: email,
          FirebaseFieldName.phoneNumber: phoneNumber,
          FirebaseFieldName.status: status,
          FirebaseFieldName.role: role,
        });

  factory UserInfoModel.fromJson(Map<String, dynamic> json,
      [String docId = ""]) {
    return UserInfoModel(
      userId: json[FirebaseFieldName.userId],
      displayName: json[FirebaseFieldName.displayName] ?? '',
      email: json[FirebaseFieldName.email],
      phoneNumber: json[FirebaseFieldName.phoneNumber] ?? "",
      status: json[FirebaseFieldName.status] ?? "",
      role: json[FirebaseFieldName.role] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        FirebaseFieldName.userId: userId,
        FirebaseFieldName.displayName: displayName,
        FirebaseFieldName.email: email,
        FirebaseFieldName.phoneNumber: phoneNumber,
        FirebaseFieldName.role: role,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserInfoModel &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          displayName == other.displayName &&
          email == other.email &&
          phoneNumber == other.phoneNumber &&
          status == other.status &&
          role == other.role;

  @override
  int get hashCode => Object.hashAll(
        [
          userId,
          displayName,
          email,
          phoneNumber,
          status,
          role,
        ],
      );
}
