# Firebase Profile Integration

## 🎯 **Overview**

The `ProfileView` has been updated to fetch user details directly from Firebase instead of relying only on local storage. This ensures that user data is always up-to-date and consistent across devices.

## 🔄 **Changes Made**

### **1. Updated Imports**
```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:monami/src/data/state/constants/firebase_collection.dart';
import 'package:monami/src/data/state/constants/firebase_field_name.dart';
```

### **2. Enhanced `_loadUserProfile()` Method**

#### **Before:**
- Only used `StorageService.getUserProfile()` (local storage)
- No real-time data from Firebase

#### **After:**
- **Primary**: Fetches user data from Firebase Firestore
- **Fallback 1**: Uses Firebase Auth user data if Firestore data not found
- **Fallback 2**: Uses local storage if Firebase fails
- **Loading State**: Shows loading indicator while fetching data

### **3. Data Flow**

```
1. Get current Firebase Auth user
   ↓
2. Query Firestore for user details using UID
   ↓
3. If found: Use Firestore data
   ↓
4. If not found: Use Firebase Auth data
   ↓
5. If Firebase fails: Use local storage
```

### **4. User Data Structure**

The profile now displays:
- **Name**: From Firestore `displayName` field
- **Email**: From Firestore `email` field or Firebase Auth
- **Phone**: From Firestore `phoneNumber` field
- **Status**: From Firestore `status` field
- **Role**: From Firestore `role` field
- **Last Login**: Current timestamp

### **5. Enhanced Logout**

```dart
// Before: Only cleared local storage
await StorageService.clearAllData();

// After: Proper Firebase logout
await FirebaseAuth.instance.signOut();
await StorageService.clearAllData();
```

## 🛠️ **Technical Implementation**

### **Firebase Query**
```dart
final userDoc = await FirebaseFirestore.instance
    .collection(FirebaseCollectionName.users)
    .where(FirebaseFieldName.userId, isEqualTo: firebaseUser.uid)
    .get();
```

### **Data Mapping**
```dart
userProfile = {
  'id': userData[FirebaseFieldName.userId],
  'name': userData[FirebaseFieldName.displayName] ?? 'User',
  'email': userData[FirebaseFieldName.email] ?? firebaseUser.email ?? 'user@email.com',
  'phone': userData[FirebaseFieldName.phoneNumber] ?? '',
  'status': userData[FirebaseFieldName.status] ?? 'active',
  'role': userData[FirebaseFieldName.role] ?? 'user',
  'lastLogin': DateTime.now().toIso8601String(),
};
```

### **Loading State**
```dart
bool isLoading = true;

// Show loading indicator
if (isLoading) {
  return const Scaffold(
    body: Center(
      child: CircularProgressIndicator(),
    ),
  );
}
```

## 🎯 **Benefits**

### **1. Real-time Data**
- ✅ User data is always current
- ✅ Changes reflect immediately
- ✅ No stale data issues

### **2. Cross-device Consistency**
- ✅ Same data across all devices
- ✅ Centralized user management
- ✅ Firebase handles synchronization

### **3. Robust Error Handling**
- ✅ Multiple fallback mechanisms
- ✅ Graceful degradation
- ✅ User experience maintained

### **4. Better User Experience**
- ✅ Loading indicators
- ✅ Smooth data refresh
- ✅ Reliable logout process

## 🔧 **Firebase Collection Structure**

### **Users Collection**
```json
{
  "users": [
    {
      "uid": "firebase_auth_uid",
      "display_name": "User Name",
      "email": "user@email.com",
      "phoneNumber": "+1234567890",
      "status": "active",
      "role": "user"
    }
  ]
}
```

### **Field Names**
- `uid`: Firebase Auth UID
- `display_name`: User's display name
- `email`: User's email address
- `phoneNumber`: User's phone number
- `status`: Account status (active/inactive)
- `role`: User role (user/admin)

## 🚀 **Usage**

### **Automatic Loading**
The profile automatically loads user data when the screen opens:
```dart
@override
void initState() {
  super.initState();
  _loadUserProfile(); // Fetches from Firebase
}
```

### **Manual Refresh**
User data refreshes when returning from edit profile:
```dart
if (result == true || result == null) {
  await _loadUserProfile(); // Refreshes from Firebase
}
```

### **Logout Process**
Proper Firebase logout with data clearing:
```dart
await FirebaseAuth.instance.signOut();
await StorageService.clearAllData();
```

## ⚠️ **Important Notes**

1. **Internet Required**: Firebase queries require internet connection
2. **Fallback Mechanism**: Local storage used if Firebase fails
3. **Loading States**: UI shows loading while fetching data
4. **Error Handling**: Graceful fallback to local data
5. **Real-time Updates**: Data refreshes on screen return

## 🧪 **Testing**

### **Test Scenarios**
1. **Normal Flow**: User data loads from Firebase
2. **No Internet**: Falls back to local storage
3. **New User**: Uses Firebase Auth data
4. **Edit Profile**: Data refreshes after edit
5. **Logout**: Proper Firebase sign out

### **Expected Behavior**
- ✅ Loading indicator shows while fetching
- ✅ User data displays correctly
- ✅ Fallback works when Firebase fails
- ✅ Logout clears all data
- ✅ Profile refreshes after edits

The ProfileView now provides a robust, real-time user experience with proper Firebase integration while maintaining backward compatibility with local storage fallbacks.

