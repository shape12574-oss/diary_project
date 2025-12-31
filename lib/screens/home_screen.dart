import 'package:flutter/material.dart';
import 'package:diary_project/database/database_helper.dart';
import 'package:diary_project/models/diary_entry.dart';
import 'package:diary_project/services/location_service.dart';
import 'package:diary_project/services/sensor_service.dart';
import 'package:diary_project/services/ai_service.dart';
import 'package:diary_project/widgets/responsive_layout.dart';
import 'diary_detail_screen.dart';
import 'dart:io';

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
  String _currentActivity = 'still';

  @override
  void initState() {
    super.initState();
    _loadDiaries();
    _startSensorTracking();
  }

  Future<void> _loadDiaries() async {
    final diaries = await _dbHelper.getAllDiaries();
    setState(() {
      _diaries = diaries;
    });
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
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: _showMapView,
            tooltip: 'Map View',
          ),
        ],
      ),
      body: _diaries.isEmpty
          ? const Center(child: Text('No diaries yet. Tap camera to create one!'))
          : ListView.builder(
        itemCount: _diaries.length,
        itemBuilder: (context, index) {
          final diary = _diaries[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: diary.photoPath.isNotEmpty
                  ? Image.file(
                File(diary.photoPath),
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )
                  : const Icon(Icons.image, size: 50),
              title: Text(diary.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(diary.address),
                  Text('Activity: ${diary.activity}'),
                  Text(
                    '${diary.createdAt.day}/${diary.createdAt.month}/${diary.createdAt.year}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              trailing: Icon(
                diary.activity == 'walking' ? Icons.directions_walk :
                diary.activity == 'running' ? Icons.directions_run :
                Icons.access_time,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DiaryDetailScreen(diary: diary),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: _buildMobileLayout(),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 2,
          child: Container(
            color: Colors.grey[100],
            child: const Center(
              child: Text('Select a diary to view details'),
            ),
          ),
        ),
      ],
    );
  }

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
        address: location['address'] as String,
        activity: _currentActivity,
        photoPath: photo.path,
        aiTags: tags,
        createdAt: DateTime.now(),
      );

      await _dbHelper.insertDiary(diary);
      _loadDiaries();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Diary created successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showMapView() {
    // 可擴展為地圖視圖
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Map view coming soon!')),
    );
  }
}