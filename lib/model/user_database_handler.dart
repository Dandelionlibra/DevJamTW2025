import 'package:Wandering/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_model.dart';
import 'package:Wandering/preference_data.dart';

// 使用者資料庫，更新時需要與 Firebase 上的使用者資料同步
class UserDatabaseHandler {
  static final _databaseName = "user.db"; // 資料庫文件名
  static final _databaseVersion = 1; // 資料庫版本
  static final userTable = 'user'; // 使用者數據表名
  static var _firebaseDB = FirebaseFirestore.instance; // Firebase 實例

  UserDatabaseHandler._privateConstructor();
  static final UserDatabaseHandler instance =
      UserDatabaseHandler._privateConstructor();
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // 初始化資料庫
  _initDatabase() async {
    String documentsDirectory = await getDatabasesPath();
    String path = join(documentsDirectory, _databaseName);
    firebaseAuth();
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // 創建資料庫表
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $userTable (
            uid TEXT PRIMARY KEY,
            username TEXT,
            email TEXT,
            preferences TEXT,
            favoritePlaces TEXT
          )
          ''');
  }

  Future<void> firebaseAuth() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        print('User is signed in: ${user.uid}');
      } else {
        print('User is signed out');
      }
    });
  }

  // 插入或更新使用者資料(需要與 Firebase 上的使用者資料同步)

  Future<int> insertOrUpdateUser(UserModel user, AuthModel auth) async {
    if (auth.isAuthenticated == false) {
      return 0; // 如果使用者未登入，則不進行任何操作
    }

    Database db = await instance.database;
    // 將 UserModel 對象轉換為 Map
    Map<String, dynamic> row = user.toMap();
    row['uid'] = user.uid;
    // change to string for sqflite
    row['preferences'] = user.preferences?.toMap().toString();
    row['favoritePlaces'] = user.favoritePlaces
        .map((place) => place.toMap())
        .toList()
        .toString();

    print('row: ${row['preferences']}');

    // 嘗試更新，如果不存在則插入
    int count = await db.update(
      userTable,
      row,
      where: 'uid = ?',
      whereArgs: [user.uid],
    );
    if (count == 0) {
      count = await db.insert(userTable, row);
    }

    // 更新 Firebase 上的使用者資料
    try {
      final firebaseData = {
        'uid': user.uid,
        'travelStyles': user.preferences?.travelStyles,
        'locationTypes': user.preferences?.locationTypes,
        'accommodationTypes': user.preferences?.accommodationTypes,
        'avoidTypes': user.preferences?.avoidTypes,
      };

      await _firebaseDB
          .collection('userpreference')
          .doc(user.uid)
          .set(firebaseData, SetOptions(merge: true));
    } catch (e) {
      print('Error updating Firebase user data: $e');
    }
    return count;
  }

  // 獲取使用者資料(從雲端)
  Future<UserModel?> getUser(String uid) async {
    final dataRef = _firebaseDB.collection('userpreference').doc(uid);
    final snapshot = await dataRef.get();
    if (snapshot.exists) {
      final data = snapshot.data();
      if (data != null) {
        // 將 Map 轉換為 UserModel
        return UserModel(
          uid: uid,
          username: data['username'] ?? '',
          email: data['email'] ?? '',
          firebaseUser: FirebaseAuth.instance.currentUser!,
          preferences: UserPreferences(
            travelStyles: Set<String>.from(data['travelStyles'] ?? []),
            locationTypes: Set<String>.from(data['locationTypes'] ?? []),
            accommodationTypes: Set<String>.from(
              data['accommodationTypes'] ?? [],
            ),
            avoidTypes: Set<String>.from(data['avoidTypes'] ?? []),
          ),
        );
      }
    }
    return null;
  }
}
