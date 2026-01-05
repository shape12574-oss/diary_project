import 'package:flutter/material.dart';
import 'dart:io';
import '../database/database_helper.dart';
import '../models/diary_entry.dart';
import '../services/location_service.dart';
import '../services/sensor_service.dart';
import '../services/ai_service.dart';
import '../widgets/responsive_layout.dart';
import '../services/diary_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final LocationService _locationService = LocationService();
  final SensorService _sensorService = SensorService();
  final AIService _aiService = AIService();

  List<DiaryEntry> _diaries = [];
  String _currentActivity = 'still'; // User Activity: Still, Walk, Run
  bool _isLoading = false; // Load Status of Diaries

  @override
  void initState() {
    super.initState();
    _loadDiaries();
    _startSensorTracking();
  }

  // Load Diaries===
  Future<void> _loadDiaries() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final diaries = await _dbHelper.getAllDiaries();
      if (mounted) {
        setState(() {
          _diaries = diaries;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Load failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _startSensorTracking() {
    _sensorService.startActivityTracking((activity) {
      setState(() {
        _currentActivity = activity;
      });
    });
  }

  @override
  void dispose() {
    _sensorService.dispose();
    _aiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: _buildMobileLayout(),
      tabletBody: _buildTabletLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TravelSnap'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo),
            onPressed: _createDiaryWithPhoto,
            tooltip: 'New Diary with Photo',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDiaries,
        child: _buildBodyContent(),
      ),
    );
  }

  //
  Widget _buildBodyContent() {
    if (_isLoading && _diaries.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_diaries.isEmpty) {
      return _buildEmptyState();
    }

    return _buildDiaryList();
  }

  // === 空狀態 ===
  Widget _buildEmptyState() {
    return ListView(
      // 關鍵：ListView 讓 RefreshIndicator 可以下拉
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.book_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('No diaries yet', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text('Create First Diary'),
                  onPressed: _createDiaryWithPhoto,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Diary List
  Widget _buildDiaryList() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(), // Scroll Down to refresh
      itemCount: _diaries.length,
      itemBuilder: (context, index) {
        final diary = _diaries[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: InkWell(
            // Click to view diary
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DiaryDetailScreen(diary: diary),
                ),
              ).then((_) => _loadDiaries()); // 返回時刷新
            },
            // 長按刪除
            onLongPress: () => _deleteDiaryFromList(diary),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: _buildDiaryImage(diary),
              title: Text(
                diary.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: _buildDiaryInfo(diary),
              trailing: _buildActivityIcon(diary),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDiaryImage(DiaryEntry diary) {
    if (diary.photoPath.isNotEmpty && File(diary.photoPath).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(diary.photoPath),
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.broken_image, size: 60);
          },
        ),
      );
    }
    return const Icon(Icons.image_not_supported, size: 60);
  }

  Widget _buildDiaryInfo(DiaryEntry diary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          diary.address,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              '${diary.createdAt.day}/${diary.createdAt.month}/${diary.createdAt.year}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        if (diary.aiTags.isNotEmpty) ...[
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            runSpacing: 2,
            children: diary.aiTags.take(3).map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                tag,
                style: TextStyle(fontSize: 10, color: Colors.blue[800]),
              ),
            )).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildActivityIcon(DiaryEntry diary) {
    return Icon(
      diary.activity == 'running' ? Icons.directions_run :
      diary.activity == 'walking' ? Icons.directions_walk :
      Icons.access_time,
      color: Colors.blue,
    );
  }

  // === TABLET LAYOUT ===
  Widget _buildTabletLayout() {
    // 平板暫時使用移動佈局（可擴展）
    return _buildMobileLayout();
  }

  // === 核心功能：創建日記 ===
  Future<void> _createDiaryWithPhoto() async {
    try {
      final photo = await _aiService.pickImage();
      if (photo == null) return;

      final location = await _locationService.getCurrentLocation();
      final tags = await _aiService.labelImage(photo);

      final diary = DiaryEntry(
        title: 'My Journey #${_diaries.length + 1}',
        content: 'Automatically generated diary entry',
        latitude: location['latitude'] as double,
        longitude: location['longitude'] as double,
        address: location['address'] as String? ?? 'Unknown',
        activity: _currentActivity,
        photoPath: photo.path,
        aiTags: tags.isEmpty ? ['no-tags'] : tags,
        createdAt: DateTime.now(),
      );

      await _dbHelper.insertDiary(diary);
      _loadDiaries(); // 刷新列表

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Diary created successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  // === 增強刪除功能：長按刪除 ===
  Future<void> _deleteDiaryFromList(DiaryEntry diary) async {
    // 顯示確認對話框
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Diary'),
        content: Text('Delete "${diary.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        final count = await _dbHelper.deleteDiary(diary.id!);
        if (count > 0) {
          // 立即從 UI 移除
          setState(() {
            _diaries.removeWhere((d) => d.id == diary.id);
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Diary "${diary.title}" deleted'),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {
                    // 撤銷刪除
                    _dbHelper.insertDiary(diary);
                    _loadDiaries();
                  },
                ),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Delete failed: $e')),
          );
        }
      }
    }
  }
}