import 'dart:io';
import 'package:devjam_tw2025/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'auth.dart';
import 'package:devjam_tw2025/data/today_data.dart';
import 'pages/food_record.dart';
import 'pages/fitness_record.dart';
import 'pages/exposure_trend.dart';
import 'package:devjam_tw2025/pages/pollution_distribution.dart';
import 'package:devjam_tw2025/page/all_page.dart';
import 'pages/traffic_record.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:devjam_tw2025/widgets/custom_drawer.dart';
import 'package:devjam_tw2025/pages/pollution_exposure_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Supabase.initialize(
    url: 'https://your-supabase-url.supabase.co', // 替換為您的 Supabase URL
    anonKey: 'your-anon-key', // 替換為您的 Supabase anon key
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthModel()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SilverGo',
      theme: ThemeData(
        primaryColor: Colors.blueGrey[900],
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          primary: Colors.blueGrey[900],
          secondary: Colors.orangeAccent,
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black54),
          titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginPage(), // 啟動時顯示登錄頁面
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  List<ExposureRecord> _todaysRecords = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAndLoadData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("App 回到前台，重新整理資料...");
      _initializeAndLoadData();
    }
  }

  Future<void> _initializeAndLoadData() async {
    try {
      await _loadRecords();
    } catch (e) {
      print('初始化數據失敗: $e');
    }
  }

  Future<void> _loadRecords() async {
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase
          .from('exposure_records') // 假設您的表名為 exposure_records
          .select()
          .eq('uid', Provider.of<AuthModel>(context, listen: false).user?.uid as String? ?? '')
          .get();
      if (response.data != null) {
        setState(() {
          _todaysRecords = (response.data as List).map((json) => ExposureRecord.fromJson(json)).toList();
        });
      }
    } catch (e) {
      print('載入記錄失敗: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  List<Widget> _getPages() {
    return [
      PollutionExposureScreen(
        records: _todaysRecords,
        onDelete: _deleteRecord,
        onEdit: _editRecord,
      ),
      const ExposureTrendScreen(),
      const FoodRecordScreen(),
      const TrafficRecordScreen(),
      const FitnessRecordScreen(),
      const PollutionDistributionScreen(),
      const LoginPage(),
    ];
  }

  final List<String> _pageTitles = const [
    '今日汙染暴露',
    '暴露趨勢圖',
    '食物紀錄',
    '交通紀錄',
    '健身紀錄',
    '汙染分布圖',
    '行為建議',
  ];

  void _showAddTaskDialog() {
    String? dialogCategory;
    final noteController = TextEditingController();
    final transportModeController = TextEditingController();
    final exerciseLocationController = TextEditingController();
    final durationController = TextEditingController();
    String? intensity;
    String? imagePath;

    final ImagePicker _picker = ImagePicker();
    final String? uid = Provider.of<AuthModel>(context, listen: false).user?.uid;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text('新增紀錄'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => setDialogState(() => dialogCategory = '食物'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: dialogCategory == '食物' ? Colors.orangeAccent : null,
                          ),
                          child: const Icon(Icons.restaurant),
                        ),
                        ElevatedButton(
                          onPressed: () => setDialogState(() => dialogCategory = '交通'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: dialogCategory == '交通' ? Colors.orangeAccent : null,
                          ),
                          child: const Icon(Icons.directions_car),
                        ),
                        ElevatedButton(
                          onPressed: () => setDialogState(() => dialogCategory = '健身'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: dialogCategory == '健身' ? Colors.orangeAccent : null,
                          ),
                          child: const Icon(Icons.fitness_center),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (dialogCategory != null) ...[
                      TextField(
                        controller: noteController,
                        decoration: InputDecoration(
                          labelText: dialogCategory == '食物' ? '輸入食物·活動量' :
                          dialogCategory == '健身' ? '輸入健身活動量' : '輸入活動名稱',
                        ),
                        keyboardType: TextInputType.text,
                      ),
                      if (dialogCategory == '交通')
                        TextField(
                          controller: transportModeController,
                          decoration: const InputDecoration(labelText: '交通方式'),
                          keyboardType: TextInputType.text,
                        ),
                      if (dialogCategory == '健身')
                        TextField(
                          controller: exerciseLocationController,
                          decoration: const InputDecoration(labelText: '運動地點'),
                          keyboardType: TextInputType.text,
                        ),
                      if (dialogCategory == '健身' || dialogCategory == '交通')
                        TextField(
                          controller: durationController,
                          decoration: const InputDecoration(labelText: '持續時間 (分鐘)'),
                          keyboardType: TextInputType.number,
                        ),
                      if (dialogCategory == '健身')
                        DropdownButton<String>(
                          value: intensity,
                          hint: const Text('選擇運動強度'),
                          items: const [
                            DropdownMenuItem(value: '低', child: Text('低')),
                            DropdownMenuItem(value: '中', child: Text('中')),
                            DropdownMenuItem(value: '高', child: Text('高')),
                          ],
                          onChanged: (value) {
                            setDialogState(() {
                              intensity = value;
                            });
                          },
                        ),
                      if (dialogCategory == '食物')
                        ElevatedButton(
                          onPressed: () async {
                            final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
                            if (pickedImage != null) {
                              setDialogState(() {
                                imagePath = pickedImage.path;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('圖片選擇成功')),
                              );
                            }
                          },
                          child: const Text('上傳圖片或拍照'),
                        ),
                      if (dialogCategory == '食物' && imagePath != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Image.file(
                            File(imagePath!),
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final note = noteController.text.trim();
                    final transportMode = transportModeController.text.trim();
                    final exerciseLocation = exerciseLocationController.text.trim();
                    final duration = int.tryParse(durationController.text.trim());

                    if (dialogCategory != null && note.isNotEmpty && uid != null) {
                      final newRecord = ExposureRecord(
                        uid: uid,
                        eventType: dialogCategory!,
                        note: note,
                        transportMode: dialogCategory == '交通' ? transportMode : null,
                        startTime: DateTime.now().toIso8601String(),
                        endTime: null,
                        exerciseLocation: dialogCategory == '健身' ? exerciseLocation : null,
                        intensity: dialogCategory == '健身' ? intensity : null,
                        durationMinutes: (dialogCategory == '健身' || dialogCategory == '交通') ? duration : null,
                        imagePath: dialogCategory == '食物' ? imagePath : null,
                      );
                      try {
                        final updatedRecord = await ExposureRecord.addRecord(newRecord);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('新增成功: ${updatedRecord.eventType} - ${updatedRecord.note}')),
                          );
                          if (updatedRecord.photoUrl != null) {
                            print('Photo URL to save: ${updatedRecord.photoUrl}');
                          }
                          Navigator.pop(context);
                          await _initializeAndLoadData(); // 刷新數據
                        }
                      } catch (e) {
                        print('Debug - Upload Error: $e');
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('新增失敗，請檢查輸入或重試')),
                          );
                        }
                      }
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('請填寫所有必要字段或確保已登錄')),
                        );
                      }
                    }
                  },
                  child: const Text('新增'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        noteController.dispose();
        transportModeController.dispose();
        exerciseLocationController.dispose();
        durationController.dispose();
      });
    });
  }

  void _showEditTaskDialog(ExposureRecord record) {
    final noteController = TextEditingController(text: record.note ?? '');
    final transportModeController = TextEditingController(text: record.transportMode ?? '');
    final exerciseLocationController = TextEditingController(text: record.exerciseLocation ?? '');
    final durationController = TextEditingController(
      text: record.durationMinutes?.toString() ?? '',
    );
    String? intensity = record.intensity;
    String? imagePath = record.imagePath;

    final ImagePicker _picker = ImagePicker();
    String selectedCategory = record.eventType;
    final String? uid = Provider.of<AuthModel>(context, listen: false).user?.uid;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text('編輯紀錄'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: selectedCategory == '食物' ? null : () => setDialogState(() => selectedCategory = '食物'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedCategory == '食物' ? Colors.orangeAccent : null,
                            foregroundColor: selectedCategory == '食物' ? Colors.white : null,
                          ),
                          child: const Icon(Icons.restaurant),
                        ),
                        ElevatedButton(
                          onPressed: selectedCategory == '交通' ? null : () => setDialogState(() => selectedCategory = '交通'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedCategory == '交通' ? Colors.orangeAccent : null,
                            foregroundColor: selectedCategory == '交通' ? Colors.white : null,
                          ),
                          child: const Icon(Icons.directions_car),
                        ),
                        ElevatedButton(
                          onPressed: selectedCategory == '健身' ? null : () => setDialogState(() => selectedCategory = '健身'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedCategory == '健身' ? Colors.orangeAccent : null,
                            foregroundColor: selectedCategory == '健身' ? Colors.white : null,
                          ),
                          child: const Icon(Icons.fitness_center),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: noteController,
                      decoration: InputDecoration(
                        labelText: selectedCategory == '食物' ? '輸入食物·活動量' :
                        selectedCategory == '健身' ? '輸入健身活動量' : '輸入活動名稱',
                      ),
                      keyboardType: TextInputType.text,
                    ),
                    if (selectedCategory == '交通')
                      TextField(
                        controller: transportModeController,
                        decoration: const InputDecoration(labelText: '交通方式'),
                        keyboardType: TextInputType.text,
                      ),
                    if (selectedCategory == '健身')
                      TextField(
                        controller: exerciseLocationController,
                        decoration: const InputDecoration(labelText: '運動地點'),
                        keyboardType: TextInputType.text,
                      ),
                    if (selectedCategory == '健身' || selectedCategory == '交通')
                      TextField(
                        controller: durationController,
                        decoration: const InputDecoration(labelText: '持續時間 (分鐘)'),
                        keyboardType: TextInputType.number,
                      ),
                    if (selectedCategory == '健身')
                      DropdownButton<String>(
                        value: intensity,
                        hint: const Text('選擇運動強度'),
                        items: const [
                          DropdownMenuItem(value: '低', child: Text('低')),
                          DropdownMenuItem(value: '中', child: Text('中')),
                          DropdownMenuItem(value: '高', child: Text('高')),
                        ],
                        onChanged: (value) {
                          setDialogState(() {
                            intensity = value;
                          });
                        },
                      ),
                    if (selectedCategory == '食物')
                      ElevatedButton(
                        onPressed: () async {
                          final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
                          if (pickedImage != null) {
                            setDialogState(() {
                              imagePath = pickedImage.path;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('圖片選擇成功')),
                            );
                          }
                        },
                        child: const Text('上傳圖片或拍照'),
                      ),
                    if (selectedCategory == '食物' && imagePath != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Image.file(
                          File(imagePath!),
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final note = noteController.text.trim();
                    final transportMode = transportModeController.text.trim();
                    final exerciseLocation = exerciseLocationController.text.trim();
                    final duration = int.tryParse(durationController.text.trim());

                    if (note.isNotEmpty && uid != null) {
                      final updatedRecord = ExposureRecord(
                        uid: uid,
                        eventType: selectedCategory,
                        note: note,
                        transportMode: selectedCategory == '交通' ? transportMode : null,
                        startTime: record.startTime,
                        endTime: record.endTime,
                        exerciseLocation: selectedCategory == '健身' ? exerciseLocation : null,
                        intensity: selectedCategory == '健身' ? intensity : null,
                        durationMinutes: (selectedCategory == '健身' || selectedCategory == '交通') ? duration : null,
                        imagePath: selectedCategory == '食物' ? imagePath ?? record.imagePath : null,
                      );
                      try {
                        final result = await ExposureRecord.addRecord(updatedRecord);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('編輯成功: ${result.eventType} - ${result.note}')),
                          );
                          if (result.photoUrl != null) {
                            print('Photo URL to save: ${result.photoUrl}');
                          }
                          Navigator.pop(context);
                          await _initializeAndLoadData(); // 刷新數據
                        }
                      } catch (e) {
                        print('Debug - Upload Error: $e');
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('編輯失敗，請重試')),
                          );
                        }
                      }
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('請填寫所有必要字段或確保已登錄')),
                        );
                      }
                    }
                  },
                  child: const Text('保存'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        noteController.dispose();
        transportModeController.dispose();
        exerciseLocationController.dispose();
        durationController.dispose();
      });
    });
  }

  Future<void> _deleteRecord(int id) async {
    final supabase = Supabase.instance.client;
    try {
      await supabase
          .from('exposure_records')
          .delete()
          .eq('id', id) // 假設每個記錄有 id 欄位
          .get();
      await _initializeAndLoadData();
    } catch (e) {
      print('刪除記錄失敗: $e');
    }
  }

  void _editRecord(ExposureRecord record) {
    _showEditTaskDialog(record);
  }

  void _onDrawerItemTapped(int index, String title) {
    if (index < _getPages().length) {
      setState(() {
        _selectedIndex = index;
      });
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final pages = _getPages();
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_selectedIndex]),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _selectedIndex < pages.length
          ? pages[_selectedIndex]
          : const Center(child: Text("頁面不存在")),
      drawer: CustomDrawer(
        authModel: Provider.of<AuthModel>(context),
        onLogout: () async {
          await Provider.of<AuthModel>(context, listen: false).logout();
          if (mounted) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
          }
        },
        onItemTapped: _onDrawerItemTapped,
        selectedIndex: _selectedIndex,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(Icons.add),
      ),
    );
  }
}