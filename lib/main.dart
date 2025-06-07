import 'dart:io';
import 'package:devjam_tw2025/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'auth.dart';
import 'data/today data.dart';
import 'pages/food_record.dart';
import 'pages/fitness_record.dart';
import 'pages/exposure_trend.dart';
import 'pages/pollution_distribution.dart';
import 'pages/traffic_record.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      home: const HomeScreen(),
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
    // Placeholder: Replace with API call if records are fetched from server
    if (mounted) {
      setState(() {
        _todaysRecords = []; // Clear or fetch from server if implemented
      });
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

                    if (dialogCategory != null && note.isNotEmpty) {
                      final newRecord = ExposureRecord(
                        uid: 'user123', // Replace with actual UID from AuthModel or Firebase
                        eventType: dialogCategory!,
                        note: note,
                        transportMode: dialogCategory == '交通' ? transportMode : null,
                        startTime: DateTime.now().toIso8601String(),
                        endTime: null, // Can be set if end time is needed
                        exerciseLocation: dialogCategory == '健身' ? exerciseLocation : null,
                        intensity: dialogCategory == '健身' ? intensity : null,
                        durationMinutes: (dialogCategory == '健身' || dialogCategory == '交通') ? duration : null,
                        imagePath: dialogCategory == '食物' ? imagePath : null, // Added imagePath
                      );
                      try {
                        await ExposureRecord.addRecord(newRecord);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('新增成功: ${newRecord.eventType} - ${newRecord.note}')),
                          );
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        print('Debug - Webhook Error: $e');
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('新增失敗，請檢查輸入或重試')),
                          );
                        }
                      }
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('請填寫所有必要字段')),
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
    String? imagePath = record.imagePath; // Fixed: Now valid due to added imagePath

    final ImagePicker _picker = ImagePicker();
    String selectedCategory = record.eventType;

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

                    if (note.isNotEmpty) {
                      final updatedRecord = ExposureRecord(
                        uid: record.uid,
                        eventType: selectedCategory,
                        note: note,
                        transportMode: selectedCategory == '交通' ? transportMode : null,
                        startTime: record.startTime,
                        endTime: record.endTime,
                        exerciseLocation: selectedCategory == '健身' ? exerciseLocation : null,
                        intensity: selectedCategory == '健身' ? intensity : null,
                        durationMinutes: (selectedCategory == '健身' || selectedCategory == '交通') ? duration : null,
                        imagePath: selectedCategory == '食物' ? imagePath ?? record.imagePath : null, // Updated
                      );
                      try {
                        await ExposureRecord.addRecord(updatedRecord);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('編輯成功: ${updatedRecord.eventType} - ${updatedRecord.note}')),
                          );
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        print('Debug - Webhook Error: $e');
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('編輯失敗，請重試')),
                          );
                        }
                      }
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('請填寫所有必要字段')),
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
    // Placeholder: Implement delete logic via Webhook if supported by the server
    print('Delete record with id: $id');
  }

  void _editRecord(ExposureRecord record) {
    _showEditTaskDialog(record);
  }

  void _onDrawerItemTapped(int index) {
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

class PollutionExposureScreen extends StatelessWidget {
  final List<ExposureRecord> records;
  final Function(int) onDelete;
  final Function(ExposureRecord) onEdit;

  const PollutionExposureScreen({
    super.key,
    required this.records,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Text(
            '今日汙染暴露',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: records.isEmpty
                ? const Center(child: Text('今日尚無紀錄，點擊右下角按鈕新增。'))
                : ListView.builder(
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                final IconData iconData;
                switch (record.eventType) {
                  case '食物':
                    iconData = Icons.restaurant;
                    break;
                  case '交通':
                    iconData = Icons.directions_car;
                    break;
                  case '健身':
                    iconData = Icons.fitness_center;
                    break;
                  default:
                    iconData = Icons.help_outline;
                }
                return ExposureCard(
                  icon: iconData,
                  title: record.note ?? '無標題',
                  subtitle: '${record.durationMinutes != null ? '時間: ${record.durationMinutes} 分鐘' : ''}'
                      '${record.intensity != null ? ' | 強度: ${record.intensity}' : ''}'
                      '${record.transportMode != null ? ' | 交通: ${record.transportMode}' : ''}'
                      '${record.exerciseLocation != null ? ' | 地點: ${record.exerciseLocation}' : ''}'
                      '${record.imagePath != null ? ' | 有圖片' : ''}', // Added imagePath check
                  onDelete: () => onDelete(index), // Use index as placeholder
                  onEdit: () => onEdit(record),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ExposureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ExposureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 32),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blueAccent),
              tooltip: '編輯紀錄',
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: '刪除紀錄',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class CustomDrawer extends StatelessWidget {
  final Function(int) onItemTapped;
  final int selectedIndex;

  const CustomDrawer({
    super.key,
    required this.onItemTapped,
    required this.selectedIndex,
  });

  Widget _buildPngIcon(String assetPath) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 30,
        minHeight: 30,
        maxWidth: 30,
        maxHeight: 30,
      ),
      child: Image.asset(
        assetPath,
        width: 28,
        height: 28,
        fit: BoxFit.contain,
        errorBuilder: (BuildContext context, error, stackTrace) {
          return const Icon(Icons.error, size: 28, color: Colors.red);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
            ),
            child: const Text(
              '使用者名稱',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildDrawerItem(
            context,
            index: 0,
            icon: const Icon(Icons.home),
            title: '今日汙染暴露',
          ),
          _buildDrawerItem(
            context,
            index: 1,
            icon: _buildPngIcon('assets/icons/icons8-increase-64.png'),
            title: '暴露趨勢圖',
          ),
          _buildDrawerItem(
            context,
            index: 2,
            icon: _buildPngIcon('assets/icons/icons8-kitchen-50.png'),
            title: '食物紀錄',
          ),
          _buildDrawerItem(
            context,
            index: 3,
            icon: _buildPngIcon('assets/icons/icons8-car-50.png'),
            title: '交通紀錄',
          ),
          _buildDrawerItem(
            context,
            index: 4,
            icon: _buildPngIcon('assets/icons/icons8-weightlifting-50.png'),
            title: '健身紀錄',
          ),
          _buildDrawerItem(
            context,
            index: 5,
            icon: _buildPngIcon('assets/icons/icons8-pie-chart-30.png'),
            title: '汙染分布圖',
          ),
          _buildDrawerItem(
            context,
            index: 6,
            icon: _buildPngIcon('assets/icons/icons8-user-24.png'),
            title: '行為建議',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, {
        required int index,
        required Widget icon,
        required String title,
      }) {
    return ListTile(
      leading: icon,
      title: Text(
        title,
        style: TextStyle(
          color: selectedIndex == index ? Theme.of(context).colorScheme.primary : Colors.black87,
          fontWeight: selectedIndex == index ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: selectedIndex == index,
      selectedTileColor: Colors.blueGrey.withOpacity(0.1),
      onTap: () => onItemTapped(index),
    );
  }
}