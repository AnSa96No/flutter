import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  // テキストコントローラーを作成
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _eventDateController = TextEditingController();
  final TextEditingController _eventLocationController =
      TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _createProject() async {
    if (_nameController.text.isEmpty || _nameController.text.trim().isEmpty) {
      // イベント名が空の場合のエラーメッセージ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('イベント名を入力してください')),
      );
      return;
    }

    if (_eventDateController.text.isEmpty ||
        _eventDateController.text.trim().isEmpty) {
      // 日程が空の場合のエラーメッセージ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('イベントの日程を入力してください')),
      );
      return;
    }

    try {
      // Firestore の自動 ID を使ってプロジェクトを作成
      await _firestore.collection('projects').add({
        'name': _nameController.text,
        "date": _eventDateController.text,
        "location": _eventLocationController.text,
        'description': _descriptionController.text,
        'createdAt': FieldValue.serverTimestamp(),
        'roles': {
          'user123': 'admin', // 仮のロールデータ
          'user456': 'viewer',
        },
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('プロジェクトを作成しました')),
      );

      // フィールドをクリア
      _nameController.clear();
      _eventDateController.clear();
      _eventLocationController.clear();
      _descriptionController.clear();
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('エラーが発生しました: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プロジェクト作成'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '新しいプロジェクトを作成します',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'プロジェクト名',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _eventDateController,
              decoration: const InputDecoration(
                labelText: '日程',
                border: OutlineInputBorder(),
                hintText: '例: 2024-12-31',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _eventLocationController,
              decoration: const InputDecoration(
                labelText: '場所',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'プロジェクトの詳細',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _createProject,
              icon: const Icon(Icons.add),
              label: const Text('作成'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
