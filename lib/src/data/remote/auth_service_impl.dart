import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:monami/src/data/local/local_cache.dart';
import 'package:monami/src/data/remote/auth_service.dart';
import 'package:monami/src/data/state/api_response.dart';
import 'package:monami/src/data/state/constants/firebase_collection.dart';
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
      return await _firestore
          .collection(FirebaseCollectionName.users)
          .where("id", isEqualTo: userId)
          .get()
          .then((user) => UserInfoModel.fromJson(
                user.docs.first.data(),
                user.docs.first.id,
              ));
    } catch (e) {
      _logger.log(e);
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
        throw const ApiErrorResponse(message: "Login failed");
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
