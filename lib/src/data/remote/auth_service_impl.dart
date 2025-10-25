import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:monami/src/data/local/local_cache.dart';
import 'package:monami/src/data/remote/auth_service.dart';
import 'package:monami/src/data/state/api_response.dart';
import 'package:monami/src/data/state/constants/firebase_collection.dart';
import 'package:monami/src/data/state/constants/firebase_field_name.dart';
import 'package:monami/src/data/state/user_info/models/user_info_model.dart';
import 'package:monami/src/utils/logger.dart';

class AuthServiceImpl implements AuthService {
  late final _logger = Logger(AuthServiceImpl);

  late LocalCache _localCache;
  late final FirebaseAuth _auth = FirebaseAuth.instance;
  late final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthServiceImpl({required LocalCache localCache}) {
    _localCache = localCache;
  }

  @override
  Future<void> deleteAccount(String id) async {
    try {
      // await _auth.
      return await _firestore
          .collection(FirebaseCollectionName.users)
          .where("id", isEqualTo: id)
          .get()
          .then((value) => null);
    } catch (e) {
      _logger.log(e);
    }
  }

  @override
  Future<UserInfoModel?> getUser(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseCollectionName.users)
          .where(FirebaseFieldName.userId, isEqualTo: userId)
          .get();
      
      if (querySnapshot.docs.isEmpty) {
        _logger.log('No user found with userId: $userId');
        return null;
      }
      
      return UserInfoModel.fromJson(
        querySnapshot.docs.first.data(),
        querySnapshot.docs.first.id,
      );
    } catch (e) {
      _logger.log('Error getting user: $e');
      return null;
    }
  }

  @override
  Stream<List<UserInfoModel>> getUsers() {
    return _firestore.collection(FirebaseCollectionName.users).snapshots().map(
          (snapshot) => List<UserInfoModel>.from(
            snapshot.docs.map(
              (document) => UserInfoModel.fromJson(
                document.data(),
              ),
            ),
          ),
        );
  }

  @override
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) throw const ApiErrorResponse(message: "Login failed");
      final appUser = await getUser(user.uid);

      if (appUser == null) {
        _logger.log('User not found in Firestore for UID: ${user.uid}');
        throw const ApiErrorResponse(message: "User profile not found. Please contact support.");
      }

      await _localCache.saveUserId(user.uid);
      await _localCache.persistLoginStatus(true);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw const ApiErrorResponse(
          message: 'No user found for that email. Sign up instead.',
        );
      } else if (e.code == 'wrong-password') {
        throw const ApiErrorResponse(message: 'Incorrect password');
      } else {
        throw ApiErrorResponse(message: e.message ?? "Login failed");
      }
    } catch (e, trace) {
      _logger.log(e);
      _logger.log(trace);
      throw const ApiErrorResponse(message: "Login failed");
    }
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }

  @override
  Future<UserInfoModel?> getCurrentUser() async {
    try {
      // Get current Firebase Auth user
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) {
        _logger.log('No Firebase user found');
        return null;
      }

      // Get user details from Firestore
      final userInfo = await getUser(firebaseUser.uid);
      if (userInfo == null) {
        _logger.log('User not found in Firestore for UID: ${firebaseUser.uid}');
        return null;
      }

      _logger.log('Successfully retrieved current user: ${userInfo.displayName}');
      return userInfo;
    } catch (e) {
      _logger.log('Error getting current user: $e');
      return null;
    }
  }

  @override
  Future<void> signUp({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) throw const ApiErrorResponse(message: "Sign up failed");
      await _localCache.saveUserId(user.uid);
      final ref = _firestore
          .collection(FirebaseCollectionName.users)
          .withConverter<UserInfoModel>(
              fromFirestore: (snapshot, _) =>
                  UserInfoModel.fromJson(snapshot.data()!),
              toFirestore: (user, _) => user.toJson());

      await ref.add(UserInfoModel(
        userId: user.uid,
        displayName: username,
        email: email,
        phoneNumber: "+",
        status: "active",
        role: "user",
      ));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw const ApiErrorResponse(
          message: 'No user found for that email. Sign up instead.',
        );
      } else if (e.code == 'wrong-password') {
        throw const ApiErrorResponse(message: 'Incorrect password');
      } else {
        throw ApiErrorResponse(message: e.message ?? "Sign Up failed");
      }
    } catch (e, trace) {
      _logger.log(e);
      _logger.log(trace);
      throw const ApiErrorResponse(message: "Signup failed");
    }
  }

  @override
  Future<void> blockUser(String id) {
    // TODO: implement blockUser
    throw UnimplementedError();
  }
}
