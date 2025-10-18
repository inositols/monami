abstract class LocalCache {
  ///Retrieves userId for current logged in user
  Future<String> getUserId();

  ///Saves [userId] for current logged in user
  Future<void> saveUserId(String userId);

  ///Deletes cached userId
  Future<void> deleteUserId();

  ///Saves encryption keys for current user
  Future<void> saveKeys({
    required String privateKey,
    required String publicKey,
  });

  ///Retrieves private key for current user
  Future<String> getPrivateKey();

  ///Retrieves public key for current user
  Future<String> getPublicKey();

  ///Saves `value` to cache using `key`
  Future<void> saveToLocalCache({required String key, required dynamic value});

  ///Retrieves a cached value stored with `key`
  Object? getFromLocalCache(String key);

  ///Removes cached value stored with `key` from cache
  Future<void> removeFromLocalCache(String key);

  ///Clears cache
  Future<void> clearCache();

  ///Persists login status
  Future<void> persistLoginStatus(bool isLoggedIn);

  bool getLoginStatus();

  ///Clears all cached data including user data, cart, and login status
  Future<void> clearAllData();

  ///Saves user profile data
  Future<void> saveUserProfile(Map<String, dynamic> userProfile);

  ///Clears cart data
  Future<void> clearCart();
}
