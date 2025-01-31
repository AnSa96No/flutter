import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TaskEditScreen extends StatefulWidget {
  final String taskId;
  final Map<String, dynamic> taskData;

  const TaskEditScreen({
    super.key,
    required this.taskId,
    required this.taskData,
  });

  @override
  _TaskEditScreenState createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends State<TaskEditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _assigneeController;
  DateTime? _dueDate;
  String _status = '未着手';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.taskData['name']);
    _assigneeController =
        TextEditingController(text: widget.taskData['assignee']);
    _dueDate = widget.taskData['dueDate'] != null
        ? DateFormat('yyyy-MM-dd').parse(widget.taskData['dueDate'])
        : null;
    _status = widget.taskData['status'] ?? '未着手';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _assigneeController.dispose();
    super.dispose();
  }

  /// Firestore のタスクを更新
  Future<void> _updateTask() async {
    if (_nameController.text.trim().isEmpty ||
        _assigneeController.text.trim().isEmpty ||
        _dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('すべての項目を入力してください')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(widget.taskId)
          .update({
        'name': _nameController.text.trim(),
        'dueDate': DateFormat('yyyy-MM-dd').format(_dueDate!),
        'assignee': _assigneeController.text.trim(),
        'status': _status,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('タスクを更新しました')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('更新に失敗しました: $e')),
      );
    }
  }

  /// 日付選択ダイアログ
  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('タスク編集')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'タスク名')),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(_dueDate == null
                    ? '締切日: 未選択'
                    : '締切日: ${DateFormat('yyyy-MM-dd').format(_dueDate!)}'),
                const Spacer(),
                ElevatedButton(
                    onPressed: () => _selectDueDate(context),
                    child: const Text('選択')),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
                controller: _assigneeController,
                decoration: const InputDecoration(labelText: '担当者')),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _status,
              items: ['未着手', '進行中', '完了']
                  .map((status) =>
                      DropdownMenuItem(value: status, child: Text(status)))
                  .toList(),
              onChanged: (newValue) => setState(() => _status = newValue!),
              decoration: const InputDecoration(labelText: '進行状況'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _updateTask, child: const Text('更新')),
          ],
        ),
      ),
    );
  }
}
