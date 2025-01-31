import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'task_create_screen.dart';
import 'task_detail_screen.dart';

class TaskListScreen extends StatelessWidget {
  final String projectId;

  const TaskListScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('タスク一覧')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskCreateScreen(projectId: projectId),
                ),
              );
            },
            child: const Text('タスクを追加'),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('tasks')
                  .where('projectId', isEqualTo: projectId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('タスクがありません'));
                }

                final tasks = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final taskDoc = tasks[index];
                    final taskData = taskDoc.data() as Map<String, dynamic>;

                    return Card(
                      child: ListTile(
                        title: Text(taskData['name'] ?? 'タスク名なし'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('締切日: ${taskData['dueDate'] ?? '未定'}'),
                            Text('担当者: ${taskData['assignee'] ?? '未定'}'),
                            Text('進行状況: ${taskData['status'] ?? '未定'}'),
                          ],
                        ),
                        onTap: () {
                          // タスク詳細画面に遷移
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TaskDetailScreen(
                                taskId: taskDoc.id,
                                taskData: taskData,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
