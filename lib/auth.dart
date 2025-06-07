import 'package:firebase_auth/firebase_auth.dart';
import 'model/user_model.dart';
import 'model/user_database_handler.dart';
import 'package:flutter/material.dart';

enum Errorlog {
  success,
  not_register_error,
  network_error,
  firebase_error,
  basic_error,
}

class LoginError implements Exception {
  final Errorlog error;
  final String message;
  LoginError(this.error, this.message);
}

class AuthModel extends ChangeNotifier {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  User? _user;
  static UserModel? _userModel;

  AuthModel() {
    auth.authStateChanges().listen((User? user) async { // Added async
      print('recieved Changes: user = $user');
      _user = user;
      if (user != null) {
        // Fetch user profile from database when auth state changes to logged in
        _userModel = await UserDatabaseHandler.getUserProfile(user.uid);
        if (_userModel == null) {
          // If profile not found in DB, create a basic one (e.g., for new users)
          _userModel = UserModel(
            uid: user.uid,
            username: user.displayName ?? user.email ?? '新用戶',
            email: user.email ?? '',
            firebaseUser: user,
          );
          // If profile not found, create it in the database
          _userModel = await UserDatabaseHandler.createUserProfile(_userModel!); 
        }
      } else {
        _userModel = null; // Clear user model on logout
      }
      notifyListeners();
    });
  }

  User? get user => _user;

  UserModel? get userModel => _userModel;
  set userModel(UserModel? userModel) {
    _userModel = userModel;
    notifyListeners();
  }

  bool get isAuthenticated => user != null;

  Future<LoginError> login(String email, String password) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(email: email, password: password);
      _user = userCredential.user; // Ensure _user is updated immediately
      if (_user != null) {
        _userModel = await UserDatabaseHandler.getUserProfile(_user!.uid);
        if (_userModel == null) {
          print('User profile not found for uid: ${_user!.uid}');
          print('user email:${_user!.email}');
          print('username: ${_user!.displayName}');

          return LoginError(Errorlog.basic_error, '用戶資料未找到，請註冊或聯繫管理員');
        }
      }
      print('Login successful, userModel: $_userModel');
      return LoginError(Errorlog.success, 'Login successful');
    } catch (e) {
      print('Login error details: $e, Type: ${e.runtimeType}');
      if (e is FirebaseAuthException) {
        if (e.message!.contains('network error')) {
          return LoginError(Errorlog.network_error, '錯誤：請檢查網路連線');
        } else if (e.message!.contains('no user record corresponding')) {
          return LoginError(Errorlog.not_register_error, '錯誤：此帳號尚未註冊');
        } else {
          return LoginError(Errorlog.firebase_error, '錯誤: 請檢查帳號或密碼');
        }
      } else {
        return LoginError(Errorlog.basic_error, '錯誤: $e');
      }
    }
  }

  Future<void> register(
    BuildContext context,
    String username,
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      UserCredential result = await auth.signInWithCredential(credential);
      _user = result.user; // Ensure _user is updated after sign in with credential
      await _user?.updateDisplayName(username);
      
      // 在註冊成功後，將使用者資料儲存到資料庫
      if (_user != null) {
        UserModel newUser = UserModel(
          uid: _user!.uid,
          username: username,
          email: email,
          firebaseUser: _user!,
        );
        await UserDatabaseHandler.createUserProfile(newUser);
        _userModel = newUser; // 更新 AuthModel 中的 _userModel
      }

      notifyListeners();
    } catch (e) {
      print('register Error: $e');
    }
  }

  Future<void> logout() async {
    await auth.signOut();
  }

  String getUserName() {
    if (_user != null) {
      return _user!.displayName ?? 'unknown';
    } else {
      return 'unknown';
    }
  }

  String getUserEmail() {
    if (_user != null) {
      return _user!.email ?? 'unknown';
    } else {
      return 'unknown';
    }
  }

  String getUserUid() {
    if (_user != null) {
      return _user!.uid;
    } else {
      return 'unknown';
    }
  }
}
