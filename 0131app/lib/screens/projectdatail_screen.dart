import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_202412200922/screens/project_edit_screen.dart';
import 'task_list_screen.dart';
import 'department_list_screen.dart';

class ProjectDetailScreen extends StatelessWidget {
  final String projectId;
  final Map<String, dynamic> projectData;

  const ProjectDetailScreen({
    super.key,
    required this.projectId,
    required this.projectData,
  });

  /// Firestore からプロジェクトと関連タスクを削除
  Future<void> _deleteProject(BuildContext context) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // プロジェクトの削除
      batch.delete(
          FirebaseFirestore.instance.collection('projects').doc(projectId));

      // 関連タスクの削除
      QuerySnapshot taskSnapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('projectId', isEqualTo: projectId)
          .get();

      for (var doc in taskSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('プロジェクトと関連タスクを削除しました')),
      );

      Navigator.pop(context); // 一覧画面に戻る
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('削除に失敗しました: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(projectData['name'] ?? 'プロジェクト詳細'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: '削除',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('プロジェクトの削除'),
                    content: const Text('このプロジェクトを削除しますか？'),
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
                _deleteProject(context);
              }
            },
          ),
          // 編集ボタン（右上のアイコン）
          IconButton(
              onPressed: //画面遷移
                  () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProjectEditScreen(
                      projectId: projectId,
                      projectData: projectData,
                      // projectDdata: projectData,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.edit)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('説明: ${projectData['description'] ?? 'なし'}'),
            const SizedBox(height: 16),
            Text('日程: ${projectData['date'] ?? '未定'}'),
            const SizedBox(height: 16),
            Text('場所: ${projectData['location'] ?? '未定'}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskListScreen(projectId: projectId),
                  ),
                );
              },
              child: const Text('タスク一覧を見る'),
            ),
            // 部門一覧画面へ遷移するボタン
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DepartmentListScreen(projectId: projectId),
                  ),
                );
              },
              child: const Text('部門一覧へ'),
            ),
          ],
        ),
      ),
    );
  }
}
