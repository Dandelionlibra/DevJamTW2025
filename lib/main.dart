import 'package:flutter/material.dart';
import 'data/today data.dart'; // 導入分離的資料庫檔案

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
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
      await ExposureDatabase.instance.clearOldRecords();
      await _loadRecords();
    } catch (e) {
      print('初始化數據失敗: $e');
    }
  }

  Future<void> _loadRecords() async {
    try {
      final records = await ExposureDatabase.instance.getTodaysRecords();
      if (mounted) {
        setState(() {
          _todaysRecords = records;
        });
      }
    } catch (e) {
      print('載入紀錄失敗: $e');
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
      ),
      const ExposureTrendScreen(),
      const FoodRecordScreen(),
      const TrafficRecordScreen(),
      const FitnessRecordScreen(),
      const PollutionDistributionScreen(),
      const Center(child: Text("行為建議頁面")),
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
    final activityController = TextEditingController();
    final pollutionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setDialogState) {
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
                    TextField(
                      controller: activityController,
                      decoration: const InputDecoration(labelText: '輸入食物·活動量'),
                    ),
                    TextField(
                      controller: pollutionController,
                      decoration: const InputDecoration(labelText: '污染暴露量 (μg)'),
                      keyboardType: TextInputType.number,
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
                    final activity = activityController.text;
                    final exposureStr = pollutionController.text;

                    if (dialogCategory != null &&
                        activity.isNotEmpty &&
                        exposureStr.isNotEmpty) {
                      final newRecord = ExposureRecord(
                        category: dialogCategory!,
                        activity: activity,
                        exposure: int.tryParse(exposureStr) ?? 0,
                        date: DateTime.now().toIso8601String().substring(0, 10),
                      );
                      await ExposureDatabase.instance.addRecord(newRecord);
                      await _loadRecords();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('新增成功: ${newRecord.category} - ${newRecord.activity}')),
                        );
                        Navigator.pop(context);
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('請填寫所有字段')),
                      );
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
      activityController.dispose();
      pollutionController.dispose();
    });
  }

  Future<void> _deleteRecord(int id) async {
    try {
      await ExposureDatabase.instance.deleteRecord(id);
      await _loadRecords();
    } catch (e) {
      print('刪除紀錄失敗: $e');
    }
  }

  void _onDrawerItemTapped(int index) {
    if (index < _getPages().length) {
      setState(() {
        _selectedIndex = index;
      });
    }
    Navigator.pop(context); // 關閉 Drawer
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

  const PollutionExposureScreen({
    super.key,
    required this.records,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final double totalExposure = records.fold(0, (sum, item) => sum + item.exposure);
    final double foodExposure = records.where((r) => r.category == '食物').fold(0, (sum, item) => sum + item.exposure);
    final double trafficExposure = records.where((r) => r.category == '交通').fold(0, (sum, item) => sum + item.exposure);
    final double fitnessExposure = records.where((r) => r.category == '健身').fold(0, (sum, item) => sum + item.exposure);
    const double goal = 1000;
    final double percentage = totalExposure / goal;

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
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: percentage > 1 ? 1.0 : percentage,
                  strokeWidth: 12,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                ),
              ),
              Text(
                '${(percentage * 100).toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${totalExposure.toStringAsFixed(0)} μg / ${goal.toStringAsFixed(0)} μg',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 20),
          Text(
            '食物 ${foodExposure.toStringAsFixed(0)} μg  |  交通 ${trafficExposure.toStringAsFixed(0)} μg  |  健身 ${fitnessExposure.toStringAsFixed(0)} μg',
            style: Theme.of(context).textTheme.bodyMedium,
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
                switch (record.category) {
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
                  title: record.activity,
                  subtitle: '暴露量: ${record.exposure} μg',
                  onDelete: () => onDelete(record.id!),
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

  const ExposureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 32),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          tooltip: '刪除紀錄',
          onPressed: onDelete,
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

class ExposureTrendScreen extends StatelessWidget {
  const ExposureTrendScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('暴露趨勢圖頁面'));
  }
}

class FoodRecordScreen extends StatelessWidget {
  const FoodRecordScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('食物紀錄頁面'));
  }
}

class TrafficRecordScreen extends StatelessWidget {
  const TrafficRecordScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('交通紀錄頁面'));
  }
}

class FitnessRecordScreen extends StatelessWidget {
  const FitnessRecordScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('健身紀錄頁面'));
  }
}

class PollutionDistributionScreen extends StatelessWidget {
  const PollutionDistributionScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('汙染分布圖頁面'));
  }
}