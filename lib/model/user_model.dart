import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'user_database_handler.dart';
import 'package:devjam_tw2025/auth.dart';

class UserModel {
  final String uid;
  final String username;
  final String email;
  final User? firebaseUser; // Make firebaseUser nullable
  String? gender;
  String? age;
  String? height;
  String? weight;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    this.firebaseUser, // Make firebaseUser optional in constructor
    this.gender,
    this.age,
    this.height,
    this.weight,
  });

  // Convert UserModel to Map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'gender': gender,
      'age': age,
      'height': height,
      'weight': weight,
    };
  }

  // Convert Map to UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      username: map['username'] as String,
      email: map['email'] as String,
      // firebaseUser is not stored in the database, so it's not part of fromMap
      gender: map['gender'] as String?,
      age: map['age'] as String?,
      height: map['height'] as String?,
      weight: map['weight'] as String?,
    );
  }
}
