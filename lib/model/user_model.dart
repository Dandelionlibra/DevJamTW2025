import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'user_database_handler.dart';
import 'package:devjam_tw2025/auth.dart';

class UserModel {
  final String uid;
  final User firebaseUser;
  final String username;
  final String email;
  String? gender;
  String? age;
  String? height;
  String? weight;

  UserModel({
    required this.uid,
    required this.username,
    required this.firebaseUser,
    required this.email,
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
      uid: map['uid'],
      username: map['username'],
      firebaseUser: map['firebaseUser'],
      email: map['email'],
      gender: map['gender'],
      age: map['age'],
      height: map['height'],
      weight: map['weight'],
    );
  }
}
