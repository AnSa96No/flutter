import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'task_edit_screen.dart';

class TaskDetailScreen extends StatelessWidget {
  final String taskId;
  final Map<String, dynamic> taskData;

  const TaskDetailScreen({
    super.key,
    required this.taskId,
    required this.taskData,
  });

  /// Firestore からタスクを削除
  Future<void> _deleteTask(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('tasks').doc(taskId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('タスクを削除しました')),
      );

      Navigator.pop(context); // タスク一覧画面に戻る
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('タスクの削除に失敗しました: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(taskData['name'] ?? 'タスク詳細'),
        actions: [
          // 編集ボタン
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: '編集',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      TaskEditScreen(taskId: taskId, taskData: taskData),
                ),
              );
            },
          ),
          // 削除ボタン
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: '削除',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('タスクの削除'),
                    content: const Text('このタスクを削除しますか？'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('キャンセル'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('削除'),
                      ),
                    ],
                  );
                },
              );

              if (confirm == true) {
                _deleteTask(context);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('タスク名: ${taskData['name'] ?? 'なし'}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('締切日: ${taskData['dueDate'] ?? '未定'}'),
            const SizedBox(height: 16),
            Text('担当者: ${taskData['assignee'] ?? '未定'}'),
            const SizedBox(height: 16),
            Text('進行状況: ${taskData['status'] ?? '未定'}'),
          ],
        ),
      ),
    );
  }
}
