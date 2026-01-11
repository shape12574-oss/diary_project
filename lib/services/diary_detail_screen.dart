
import 'package:flutter/material.dart';
import 'dart:io';
import '../models/diary_entry.dart';
import '../database/database_helper.dart';
import '../screens/edit_diary_screen.dart';

class DiaryDetailScreen extends StatefulWidget {
  final DiaryEntry diary;

  const DiaryDetailScreen({super.key, required this.diary});

  @override
  State<DiaryDetailScreen> createState() => _DiaryDetailScreenState();
}

class _DiaryDetailScreenState extends State<DiaryDetailScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.diary.title),
        actions: [
          // Edit button
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Diary',
            onPressed: _editDiary,
          ),
          // Delete button
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _deleteDiary();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.diary.photoPath.isNotEmpty)
                Image.file(
                  File(widget.diary.photoPath),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 16),
              _buildInfoCard(),
              const SizedBox(height: 16),
              _buildContentSection(),
              const SizedBox(height: 16),
              _buildTagsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            ListTile(
              title: const Text('Location'),
              subtitle: Text(widget.diary.address),
              leading: const Icon(Icons.location_on),
            ),
            ListTile(
              title: const Text('Activity'),
              subtitle: Text(widget.diary.activity),
              leading: const Icon(Icons.directions_walk),
            ),
            ListTile(
              title: const Text('Date'),
              subtitle: Text('${widget.diary.createdAt.day}/${widget.diary.createdAt.month}/${widget.diary.createdAt.year}'),
              leading: const Icon(Icons.calendar_today),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Content',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(widget.diary.content),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI Tags',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: widget.diary.aiTags.map((tag) => Chip(
                label: Text(tag),
                backgroundColor: Colors.blue[100],
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _editDiary() async {
    final updatedDiary = await Navigator.push<DiaryEntry>(
      context,
      MaterialPageRoute(
        builder: (_) => EditDiaryScreen(diary: widget.diary),
      ),
    );

    if (updatedDiary != null && mounted) {
      setState(() {
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Diary updated successfully!')),
      );
    }
  }

  // Dialog Box
  void _deleteDiary() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Diary'),
        content: Text('Are you sure you want to delete "${widget.diary.title}"?'),
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
      final count = await _dbHelper.deleteDiary(widget.diary.id!);
      if (count > 0 && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Diary deleted successfully!')),
        );
      }
    }
  }
}