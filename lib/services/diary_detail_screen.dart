import 'package:flutter/material.dart';
import 'dart:io';
import '../models/diary_entry.dart';

class DiaryDetailScreen extends StatelessWidget {
  final DiaryEntry diary;

  const DiaryDetailScreen({super.key, required this.diary});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(diary.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (diary.photoPath.isNotEmpty)
                Image.file(
                  File(diary.photoPath),
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
              subtitle: Text(diary.address),
              leading: const Icon(Icons.location_on),
            ),
            ListTile(
              title: const Text('Activity'),
              subtitle: Text(diary.activity),
              leading: const Icon(Icons.directions_walk),
            ),
            ListTile(
              title: const Text('Date'),
              subtitle: Text('${diary.createdAt.day}/${diary.createdAt.month}/${diary.createdAt.year}'),
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
            Text(diary.content),
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
              children: diary.aiTags.map((tag) => Chip(
                label: Text(tag),
                backgroundColor: Colors.blue[100],
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}