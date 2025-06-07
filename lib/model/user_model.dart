import 'package:Wandering/preference_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'user_database_handler.dart';
import 'package:Wandering/auth.dart';
import 'place_model.dart';

class UserModel {
  final String uid;
  final User firebaseUser;
  final String username;
  final String email;
  UserPreferences? preferences;
  List<PlaceModel> favoritePlaces = [];

  UserModel({
    required this.uid,
    required this.username,
    required this.firebaseUser,
    required this.email,
    this.preferences,
    this.favoritePlaces = const [],
  });

  // Convert UserModel to Map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'preferences': preferences?.toMap(),
      'favoritePlaces': favoritePlaces.map((place) => place.toMap()).toList(),
    };
  }

  // Convert Map to UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      username: map['username'],
      firebaseUser: map['firebaseUser'],
      email: map['email'],
      preferences: UserPreferences.fromMap(map['preferences']),
      favoritePlaces: (map['favoritePlaces'] as List)
          .map((place) => PlaceModel.fromMap(place))
          .toList(),
    );
  }

  void addFavoritePlace(PlaceModel place) {
    favoritePlaces.add(place);
  }

  bool removeFavoritePlace(PlaceModel place) {
    return favoritePlaces.remove(place);
  }

  Future<void> updatePreferences(
    BuildContext context,
    UserPreferences newPreferences,
  ) async {
    preferences = newPreferences;
    await UserDatabaseHandler.instance.insertOrUpdateUser(
      this,
      Provider.of<AuthModel>(context, listen: false),
    );
  }

  Future<void> updateTravelStyle(
    BuildContext context,
    List<String> travelStyle,
  ) async {
    preferences?.travelStyles = Set<String>.from(travelStyle);
    await UserDatabaseHandler.instance.insertOrUpdateUser(
      this,
      Provider.of<AuthModel>(context, listen: false),
    );
  }

  Future<void> updateLocationType(
    BuildContext context,
    List<String> locationType,
  ) async {
    preferences?.locationTypes = Set<String>.from(locationType);
    await UserDatabaseHandler.instance.insertOrUpdateUser(
      this,
      Provider.of<AuthModel>(context, listen: false),
    );
  }

  Future<void> updateAvoidType(
    BuildContext context,
    List<String> avoidType,
  ) async {
    preferences?.avoidTypes = Set<String>.from(avoidType);
    await UserDatabaseHandler.instance.insertOrUpdateUser(
      this,
      Provider.of<AuthModel>(context, listen: false),
    );
  }

  Future<void> updateAccommodationType(
    BuildContext context,
    List<String> accommodationType,
  ) async {
    preferences?.accommodationTypes = Set<String>.from(accommodationType);
    await UserDatabaseHandler.instance.insertOrUpdateUser(
      this,
      Provider.of<AuthModel>(context, listen: false),
    );
  }
}
