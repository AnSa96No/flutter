import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class TaskCreateScreen extends StatefulWidget {
  final String projectId;

  const TaskCreateScreen({super.key, required this.projectId});

  @override
  _TaskCreateScreenState createState() => _TaskCreateScreenState();
}

class _TaskCreateScreenState extends State<TaskCreateScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _assigneeController = TextEditingController();
  final Uuid _uuid = Uuid();
  DateTime? _dueDate; // 締切日
  String _status = '未着手'; // 進行状況のデフォルト値

  /// Firestore にタスクを追加
  Future<void> _addTask() async {
    if (_nameController.text.trim().isEmpty ||
        _assigneeController.text.trim().isEmpty ||
        _dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('すべての項目を入力してください')),
      );
      return;
    }

    final String taskId = _uuid.v4();

    await FirebaseFirestore.instance.collection('tasks').doc(taskId).set({
      'projectId': widget.projectId,
      'name': _nameController.text.trim(),
      'dueDate': DateFormat('yyyy-MM-dd').format(_dueDate!), // 締切日をフォーマット
      'assignee': _assigneeController.text.trim(),
      'status': _status, // 選択した進行状況
      'createdAt': FieldValue.serverTimestamp(),
    });

    Navigator.pop(context);
  }

  /// 日付選択ダイアログを表示
  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('タスク作成')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // タスク名
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'タスク名'),
            ),
            const SizedBox(height: 16),

            // 締切日選択
            Row(
              children: [
                Text(_dueDate == null
                    ? '締切日: 未選択'
                    : '締切日: ${DateFormat('yyyy-MM-dd').format(_dueDate!)}'),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => _selectDueDate(context),
                  child: const Text('選択'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 担当者
            TextField(
              controller: _assigneeController,
              decoration: const InputDecoration(labelText: '担当者'),
            ),
            const SizedBox(height: 16),

            // 進行状況選択
            DropdownButtonFormField<String>(
              value: _status,
              items: ['未着手', '進行中', '完了'].map((String status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _status = newValue!;
                });
              },
              decoration: const InputDecoration(labelText: '進行状況'),
            ),
            const SizedBox(height: 16),

            // 追加ボタン
            ElevatedButton(
              onPressed: _addTask,
              child: const Text('追加'),
            ),
          ],
        ),
      ),
    );
  }
}
