import 'package:firebase_auth/firebase_auth.dart';
import 'model/user_model.dart';
import 'preference_data.dart';
import 'model/user_database_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    auth.authStateChanges().listen((User? user) {
      print('recieved Changes: user = $user');
      _user = user;
      _userModel = UserModel(
        uid: user?.uid ?? '',
        username: user?.displayName ?? '',
        firebaseUser: user!,
        email: user.email ?? '',
        preferences: UserPreferences(),
      );
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
      await auth.signInWithEmailAndPassword(email: email, password: password);
      _userModel = await UserDatabaseHandler.instance.getUser(user!.uid);
      return LoginError(Errorlog.success, 'Login successful');
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.message!.contains('network error')) {
          print('Network error detected');

          // Handle network error
          return LoginError(Errorlog.network_error, '錯誤：請檢查網路連線');
        } else if (e.message!.contains('no user record corresponding')) {
          print('not register yet');
          // Handle network error
          return LoginError(Errorlog.not_register_error, '錯誤：此帳號尚未註冊');
        } else {
          print('Firebase Login Error : ${e.message}');
          // Handle other errors
          return LoginError(Errorlog.firebase_error, '錯誤: 請檢查帳號或密碼');
        }
      } else {
        print('Basic Login Error : $e');
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
      await user?.updateDisplayName(username);

      FirebaseFirestore storage = FirebaseFirestore.instance;
      await storage.collection("userperference").doc(_user!.uid).set({
        'username': username,
        'email': email,
        'travelStyles': [],
        'locationTypes': [],
        'accommodationTypes': [],
        'avoidTypes': [],
      });

      notifyListeners();
      Navigator.pop(context);
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

  UserPreferences? getUserPreferences() {
    if (_userModel != null) {
      return _userModel!.preferences;
    } else {
      return UserPreferences();
    }
  }
}
