import 'package:monami/src/data/state/user_info/models/user_info_model.dart';

abstract class AuthService {
// Sign up a user
  Future<void> signUp({
    required String email,
    required String username,
    required String password,
  });

// login a user
  Future<void> login({
    required String email,
    required String password,
  });

// log out of monami
  Future<void> logout();

//delete user data from monami
  Future<void> deleteAccount(String id);

//block user as ADMIn
  Future<void> blockUser(String id);

// get a user by [userId]
  Future<UserInfoModel?> getUser(String userId);

  //subscribe to list of users
  Stream<List<UserInfoModel>> getUsers();
}
